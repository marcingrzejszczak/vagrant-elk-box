#!/usr/bin/env bash

echo -e "Starting Zipkin and the Apps"

cd sleuth-documentation-apps
./scripts/start_with_zipkin_server.sh
cd ../
