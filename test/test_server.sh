#!/bin/bash

# This script is used to test the server.
dart bin/git_lfs_server.dart localhost 8080 60 dXNlcm5hbWU6cGFzc3dvcmQ= $1
