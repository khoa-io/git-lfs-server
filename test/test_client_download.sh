#!/bin/bash

dest_url=$1
auth_token=$2

curl -s --insecure $dest_url \
-X GET \
-H "Authorization: Basic $auth_token" | shasum -a 256 -c test/data/CHECKSUM
