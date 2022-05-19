#!/bin/sh

for i in /etc/ssh/*.pub; do echo; echo ${i}; ssh-keygen -lf ${i}; done; echo

service ssh start

export GIT_LFS_SERVER_URL="https://localhost:8443"
export GIT_LFS_SERVER_CERT="/etc/git-lfs/certificates/git-lfs-server.crt"
export GIT_LFS_SERVER_KEY="/etc/git-lfs/certificates/git-lfs-server.key"

export GIT_LFS_SERVER_TRACE=1

su `cat user.txt` -c "git-lfs-server"
