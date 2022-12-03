#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Expected to get current app url file path as first argument, but there was nothing!"
    exit 1;
fi

if [ ! -e "$1" ]; then
    echo "Current app url file doesn't exist, skipping!"
    exit 0;
fi

current_app_url=$(cat ${1})

export SKIP_RELOAD="true"
bash update_app_url.bash ${current_app_url}