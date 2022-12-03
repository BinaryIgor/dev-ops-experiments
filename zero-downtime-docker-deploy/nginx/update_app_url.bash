#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Expected to get app url as first argument, but there was nothing!"
    exit 1;
fi

export APP_URL=$1

echo "Replacing config with new app url: $APP_URL..."

envsubst '${APP_URL}' < nginx_app_template.conf > nginx_tmp.conf

cp conf/default.conf nginx_backup.conf
mv nginx_tmp.conf conf/default.conf

echo "Config updated!"

if [ -z "${SKIP_RELOAD:-}" ]; then
    NGINX_CONTAINER=${NGINX_CONTAINER:-nginx}

    docker exec ${NGINX_CONTAINER} nginx -s reload

    echo "Config reloaded, checking status after 3s..."

    sleep 3

    status=$(docker container inspect -f '{{.State.Status}}' ${NGINX_CONTAINER})
    if [ ${status} != 'running' ]; then
        echo "App is not running, go back to previous config!"
        exit 1
    fi

    echo "Nginx is running with new app url!"
fi