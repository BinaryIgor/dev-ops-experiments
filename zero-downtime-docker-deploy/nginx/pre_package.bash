#!/bin/bash
set -eu

mkdir target/conf

export APP_URL="${APP_URL:-http://0.0.0.0:9999}"

envsubst '${APP_URL}' < nginx_template.conf > target/conf/default.conf
cp nginx_template.conf target/nginx_app_template.conf

cp update_app_url.bash target/update_app_url.bash
# cp update_app_url_pre_start.bash target/update_app_url_pre_start.bash