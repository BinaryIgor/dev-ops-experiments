#!/bin/bash
set -euo pipefail

if [ -e global_ci_config.env ]; then
    source global_ci_config.env
fi

scripts_dir=${PWD}
cd ..
cd ${APP_DIR}

if [ ! -e ci_config.env ]; then
    echo "Required ci_config.env file doesn't exist!"
    exit 1
fi
source ci_config.env

tag="${TAG:-latest}"
tagged_image="${APP}:${tag}"

echo "Creating package in target directory for $tagged_image image..."
echo "Preparing target dir in $APP_DIR.."

rm -r -f target
mkdir target

echo "Building image..."

if [ -n ${PRE_PACKAGE_SCRIPT} ]; then
    echo "Running pre $PRE_PACKAGE_SCRIPT package script.."
    bash ${PRE_PACKAGE_SCRIPT}
fi

docker build . -t ${tagged_image}

gzipped_image_path="target/$APP.tar.gz"

echo "Image built, exporting it to $gzipped_image_path, this can take a while..."

docker save ${tagged_image} | gzip > ${gzipped_image_path}

echo "Image exported, preparing scripts..."

export app=$APP
export tag=$tag

export pre_run_cmd="${PRE_RUN_CMD:-}"

extra_run_args="${EXTRA_RUN_ARGS:-}"
export run_cmd="docker run -d $extra_run_args --restart unless-stopped --name $app $tagged_image"

envsubst '${app} ${tag}' < "$scripts_dir/template_load_and_run_app.bash" > target/load_and_run_app.bash
envsubst '${app} ${pre_run_cmd} ${run_cmd}' < "$scripts_dir/template_run_app.bash" > target/run_app.bash

echo "Package prepared."
