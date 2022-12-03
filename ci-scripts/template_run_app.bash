#!/bin/bash
set -eu

stop_timeout=${stop_timeout:-30}
found_container=$(docker ps -q -f name="${app}")

if [ "$found_container" ]; then
  echo "Stopping previous ${app} version..."
  docker stop ${app} --time ${stop_timeout}
fi

echo "Removing previous container...."
docker rm ${app} || true

echo
echo "Starting new ${app} version..."
echo

${pre_run_cmd}
${run_cmd}