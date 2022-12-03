#!/bin/bash
set -e

export SERVER_PORT=$(shuf -i 10000-20000 -n 1)

echo "http://0.0.0.0:$SERVER_PORT" > target/app_url.txt
echo ${SERVER_PORT} > target/app_port.txt