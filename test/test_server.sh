#!/bin/bash

# This script is used to test the server.

export GIT_LFS_SERVER_URL="https://localhost:8080"
export GIT_LFS_SERVER_CERT="${HOME}/certificates/mine.crt"
export GIT_LFS_SERVER_KEY="${HOME}/certificates/mine.key"

dart bin/git_lfs_server.dart
