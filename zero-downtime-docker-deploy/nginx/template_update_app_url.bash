#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Expected to get app url as first argument, but there was nothing!"
    exit 1;
fi

export APP_URL=$1

echo "Replacing config with new app url: $APP_URL..."

envsubst '${APP_URL}' < template_nginx_app.conf > nginx_tmp.conf

cp conf/default.conf nginx_backup.conf
mv nginx_tmp.conf conf/default.conf

echo "Config updated!"

if [ -z "${SKIP_RELOAD:-}" ]; then
    docker exec ${nginx_container} nginx -s reload
    echo "Nginx is running with new app url ($APP_URL)!"

    echo "Cheking proxied app connection.."
    curl --silent --retry-connrefused --retry 10 --retry-delay 1 --fail ${app_health_check_url}
    echo

    echo "Proxied app is healthy!"
fi
