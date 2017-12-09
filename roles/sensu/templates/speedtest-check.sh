#!/bin/bash

help(){
    echo "Usage: $0 [OPTION]..."
    echo "  -u, --upload        Only return upload result"
    echo "  -d, --download      Only return download result"
}

# Parse input args
just_upload=0
just_download=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) shift; help;;
        -u|--upload) shift; just_upload=1;;
        -d|--download) shift; just_download=1;;
        *) shift; help;;
   esac
done

if [ $just_upload -eq 1 ]; then
    source "{{sensu_venv_dir}}/bin/activate"
    speedtest-cli --json --no-download | tail -1 | jq ".upload | floor"
elif [ $just_download -eq 1 ]; then
    source "{{sensu_venv_dir}}/bin/activate"
    speedtest-cli --json --no-upload | tail -1 | jq ".download | floor"
else
    help
fi

