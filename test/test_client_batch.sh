#!/bin/bash

curl http://$1/objects/batch \
-X POST \
-H "Accept: application/vnd.git-lfs+json" \
-H "Content-Type: application/vnd.git-lfs+json" \
-H "Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" \
-d @test/data/download.json
