#!/bin/bash
set -eu

mkdir target/conf

export APP_URL="${APP_URL:-http://0.0.0.0:8080}"

envsubst '${HTTP_PORT} ${APP_URL}' < template_nginx.conf > target/conf/default.conf
envsubst '${HTTP_PORT}' < template_nginx.conf > target/template_nginx_app.conf

export nginx_container=${APP}
export app_health_check_url="http://0.0.0.0:${HTTP_PORT}/health-check"

envsubst '${nginx_container} ${app_health_check_url}' < template_update_app_url.bash > target/update_app_url.bash
envsubst '${app_health_check_url}' < template_post_run.bash > target/post_run.bash

cp update_app_url_pre_start.bash target/update_app_url_pre_start.bash