#!/bin/sh

set -e

postgres_service_dir="$1"

cd "$postgres_service_dir"
openssl req -new -newkey rsa:4096 -x509 -days 365000 -nodes -out server.crt -keyout server.key -batch
