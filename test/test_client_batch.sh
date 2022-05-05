#!/bin/bash

host_port=$1
auth_token=$2

echo "https://$host_port/objects/batch"
curl --insecure https://$host_port/objects/batch \
-X POST \
-H "Accept: application/vnd.git-lfs+json" \
-H "Content-Type: application/vnd.git-lfs+json" \
-H "Authorization: Basic $auth_token" \
-d @test/data/download.json
