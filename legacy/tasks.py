import os, shutil, urllib
import urllib

from invoke import task


@task
def install_raspbian(ctx):
    url = "https://downloads.raspberrypi.org/raspbian_lite_latest"
    print "Downloading latest version of RASPBIAN Lite from {0}".format(url)
    print "This might take a few mins..."
    filename, headers = urllib.urlretrieve(url)
    print filename
    print headers
    print headers['Content-Disposition']
    dest_path = os.path.join("/tmp", headers['Content-Disposition'].split("filename=")[1])
    shutil.copy(filename, dest_path)
    print "Download complete: {0}".format(dest_path)
    # TODO 1) put on SD card using etcher.io/cli 2) add empty ssh file



@task
def noobs(ctx, docs=False):
    """ DEPRECATED Installing NOOBS """
    # 1. Only keep os/Raspbian
    noobs_dir = os.path.abspath("NOOBS_v2_4_0")
    print "1. Only keep {}/os/Raspbian...".format(noobs_dir)
    os_dir = os.path.join(noobs_dir, "os")
    os_dirs = os.listdir(os_dir)
    for file in os_dirs:
        if file not in ["Raspbian", ".DS_Store"]:
            shutil.rmtree(os.path.join(os_dir, file))
    print "DONE"

    # 2. Modify recovery.cmdline
    print "2. Modify...".format(noobs_dir)
    recovery_file = os.path.join(noobs_dir, "recovery.cmdline")
    contents = open(recovery_file).readline()
    if not contents.endswith("silentinstall\n"):
        contents = contents.replace("\n", "") + " silentinstall\n"
        open(recovery_file, "w").write(contents)

    print "DONE"
