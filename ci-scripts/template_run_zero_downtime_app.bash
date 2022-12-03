#!/bin/bash
set -eu

stop_timeout=${stop_timeout:-30}
found_container=$(docker ps -q -f name="${app}")
app_backup="${app}-backup"

if [ "$found_container" ]; then
  echo "Renaming current ${app} version to ${app_backup}..."
  docker rename ${app} ${app_backup}
fi

echo "Removing previous container...."
docker rm ${app} || true

echo
echo "Starting new ${app} version..."
echo

${pre_run_cmd}
${run_cmd}
${post_run_cmd}

echo "New ${app} has started, checking its status after a while..."
sleep 3

status=$(docker container inspect -f '{{.State.Status}}' ${app})
if [ ${status} == 'running' ]; then
  echo "App is running, checking if its healthy..."
  curl --silent --retry-connrefused --retry 10 --retry-delay 1 --fail ${app_url}
  echo
  echo "App is running and healthy!"
else
  echo "App is not running, checking the cause, renaming it again to ${app}.."
  docker rename ${app_backup} ${app}
  echo "App renamed, exiting"
  exit 1;
fi

cwd=${PWD}
cd ${nginx_dir}
bash update_app_url.bash ${app_url}

echo
echo "Nginx config updated"

if [ "$found_container" ]; then
  echo "Stopping previous ${app} version after a while..."
  sleep 5
  docker stop ${app_backup} --time ${stop_timeout}
fi

echo "Removing renamed container..."
docker rm ${app_backup} || true

echo
echo "Zero downtime deploy of ${app} success!"