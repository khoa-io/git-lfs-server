#!/bin/bash

GIT_LFS_SERVER_URL="localhost"
GIT_LFS_EXPIRES_IN="120"

export GIT_LFS_SERVER_URL GIT_LFS_EXPIRES_IN

# This script is used to test the server.
dart bin/git_lfs_authenticate.dart $1 download
