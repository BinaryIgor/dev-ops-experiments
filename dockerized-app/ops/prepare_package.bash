#!/bin/bash
set -euo pipefail

tag="${TAG:-latest}"
tagged_image="${APP}:${tag}"

echo "Creating package in target directory for $tagged_image image..."
echo "Preparing target dir..."

cd ..
rm -r -f target
mkdir target

echo "Building image..."

docker build . -t ${tagged_image}

gzipped_image_path="target/$APP.tar.gz"

echo "Image built, exporting it to $gzipped_image_path, this can take a while..."

docker save ${tagged_image} | gzip > ${gzipped_image_path}

echo "Image exported, preparing scripts..."

export app=$APP
export tag=$tag
export run_cmd="docker run -d --restart unless-stopped --name $app $tagged_image"

envsubst '${app} ${tag}' < ops/template_load_and_run_app.bash > target/load_and_run_app.bash
envsubst '${app} ${run_cmd}' < ops/template_run_app.bash > target/run_app.bash

echo "Package prepared."
