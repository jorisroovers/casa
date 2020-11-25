#!/bin/bash

########################################################################################################################
# Gather all the inputs we need

: ${WIFI_SSID:?"WIFI_SSID env variable must be set"}
: ${WIFI_PSK:?"WIFI_PSK env variable must be set"}

# Pick Raspbian or Raspbian lite
PS3='Which Raspbian version? '
options=("raspbian_latest" "raspbian_lite_latest")
select opt in "${options[@]}"; do
    if [ ! -z "$opt" ]; then
        RASPBIAN_IMAGE="$opt"
        break
    fi
done

########################################################################################################################
# Downloading raspberry image

cd "/tmp"
DOWNLOAD_IMAGE="yes"
if [ -f "/tmp/$RASPBIAN_IMAGE" ]; then
    echo "Found an existing $RASPBIAN_IMAGE image in /tmp, checking if it's the latest..."

    echo "Downloading sha1 of latest raspberry image..."
    wget -q "https://downloads.raspberrypi.org/$RASPBIAN_IMAGE.sha1"
    SHA_LATEST=$(awk '{print $1}' /tmp/$RASPBIAN_IMAGE.sha1)

    echo "Determining checksum of local raspberry image..."
    SHA_LOCAL=$(shasum /tmp/$RASPBIAN_IMAGE | awk '{print $1}')

    echo " SHA_LOCAL = $SHA_LOCAL"
    echo "SHA_LATEST = $SHA_LATEST"
    if [ "$SHA_LOCAL" == "$SHA_LATEST" ]; then
        DOWNLOAD_IMAGE="no"
        echo "Local image is the latest - not downloading a new copy..."
    fi
fi

if [ "$DOWNLOAD_IMAGE" == "yes" ]; then
    echo "Downloading..."
    cd /tmp
    wget https://downloads.raspberrypi.org/$RASPBIAN_IMAGE
fi

echo ""
echo "Unpacking zip file (/tmp/$RASPBIAN_IMAGE -> /tmp/$RASPBIAN_IMAGE.img)..."
# Unpack the zip file into an img disk file we can copy
unzip -p /tmp/$RASPBIAN_IMAGE >/tmp/$RASPBIAN_IMAGE.img
ls -lh /tmp/$RASPBIAN_IMAGE.img

########################################################################################################################
# Danger zone: writing to the SD Card

RPI_DEVICE_DISK=$(diskutil list boot | head -n 1 | cut -d " " -f 1);
RPI_RAW_DEVICE_DISK=$(echo ${RPI_DEVICE_DISK/disk/rdisk});

# Print info for user to review
echo ""
echo "***************************************************"
echo "RASPBIAN_IMAGE=$RASPBIAN_IMAGE"
echo "RPI_DEVICE_DISK=$RPI_DEVICE_DISK"
echo "RPI_RAW_DEVICE_DISK=$RPI_RAW_DEVICE_DISK"
echo "WIFI_SSID=$WIFI_SSID"
echo "WIFI_PSK=$WIFI_PSK"
echo "***************************************************"

# Safety check: Disk should only be 15.7GB
echo "IMPORTANT: The disk below should hold 15.7 GB"
diskutil list $RPI_DEVICE_DISK

# Ask user to continue or not
echo ""
while true; do
    read -p "Do you want to continue (destructive action) [y/n]?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*)
        echo "Exiting..."
        exit
        ;;
    esac
done

# Unmount disk
echo "Unmounting disk $RPI_DEVICE_DISK..."
diskutil unmountDisk $RPI_DEVICE_DISK

# write to disk
echo "Writing image to SD card (might take a few mins)..."
sudo dd bs=1m if=/tmp/$RASPBIAN_IMAGE.img of=$RPI_RAW_DEVICE_DISK  conv=sync
sleep 10 # Extra sleep to allow remount to happen
echo "DONE"

echo ""
echo "Here's what's on disk:"
ls /Volumes/boot

echo "Enabling ssh at initial startup..."
touch /Volumes/boot/ssh

echo ""
echo "Configuring Wifi..."
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=NL\n" > /Volumes/boot/wpa_supplicant.conf
echo -e "network={\n\tssid=\"$WIFI_SSID\"\n\tpsk=\"$WIFI_PSK\"\n\tkey_mgmt=WPA-PSK\n}" >> /Volumes/boot/wpa_supplicant.conf
cat /Volumes/boot/wpa_supplicant.conf
echo "DONE"

echo "Ejecting boot disk..."
diskutil eject boot

echo "ALL DONE"