#!/bin/bash

# This script is used to test the server.

export GIT_LFS_SERVER_URL="https://localhost:8080"
export GIT_LFS_SERVER_CERT="${HOME}/certificates/mine.crt"
export GIT_LFS_SERVER_KEY="${HOME}/certificates/mine.key"

export GIT_LFS_SERVER_TRACE=1

dart pub global activate --source path .

dart pub global run git_lfs_server:git_lfs_server_install

launchctl remove com.khoa-io.git-lfs-server-agent
launchctl load ${HOME}/Library/LaunchAgents/com.khoa-io.git-lfs-server-agent.plist
launchctl start com.khoa-io.git-lfs-server-agent
launchctl list com.khoa-io.git-lfs-server-agent

git clone --mirror https://github.com/khoa-io/git-lfs-sample-repo.git /tmp/git-lfs-sample-repo-mirror.git
git --git-dir=/tmp/git-lfs-sample-repo-mirror.git lfs fetch --all
git clone ${USER}@`hostname`:/tmp/git-lfs-sample-repo-mirror.git /tmp/git-lfs-sample-repo
sha256sum /tmp/git-lfs-sample-repo/binary_file
if [ $? -eq 0 ]; then
    clone_success=1
else
    clone_success=0
fi

rm -rf /tmp/git-lfs-sample-repo-mirror.git /tmp/git-lfs-sample-repo

launchctl stop com.khoa-io.git-lfs-server-agent
cat ${HOME}/Library/Logs/com.khoa-io.git-lfs-server-agent.log
rm ${HOME}/Library/Logs/com.khoa-io.git-lfs-server-agent.log

if [ $clone_success -eq 1 ]; then
    echo PASSED!
    return 0
else
    echo FAILED!
    return 1
fi
