#!/bin/bash

GIT_LFS_SERVER_URL="localhost"
GIT_LFS_EXPIRES_IN="120"

export GIT_LFS_SERVER_URL GIT_LFS_EXPIRES_IN

mirror_path=$1

dart pub global activate --source path .

dart pub global run git_lfs_server:git_lfs_authenticate $mirror_path download
