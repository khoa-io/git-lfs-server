A simple Git LFS server implementation in Dart
===============================

# Overview

> [Git Large File Storage (LFS)](https://git-lfs.github.com) is a free, open-source extension that replaces large files with text pointers inside Git and stores the contents of those files on a remote server.
> -- [GitHub Training & Guides](https://youtu.be/uLR1RNqJ1Mw)

Git LFS protocol requires a Git server that supports LFS, and a Git LFS client. There is only one official open-source [LFS client](https://github.com/git-lfs/git-lfs.git). But there are several [LFS server implementations](https://github.com/git-lfs/git-lfs/wiki/Implementations). This implementation provides a simple solution that works with Git mirrors.

## An example that this implementation can be used for
It is recommended that you check out [Git Mirroring with LFS](https://github.com/khoa-io/git-lfs-server/wiki/Git-Mirroring-with-LFS).
This wiki page provides more details on advantages, limitations, as well as installation steps.

# Installing

## Dependencies

- [Dart SDK](https://dart.dev/get-dart)
- [Git](https://git-scm.com)
- [Git LFS](https://git-lfs.github.com)

## macOS

Modify the following script to run the server:
```bash
openssl req -x509 -sha256 -nodes -days 2100 -newkey rsa:2048 -keyout "YOUR_CERT_FILE" -out "YOUR_KEY_FILE"

git config --global http."YOUR_SERVER_URL.sslverify" false

export GIT_LFS_SERVER_URL="YOUR_SERVER_URL" # Example: "https://localhost:8080"
export GIT_LFS_SERVER_CERT= "YOUR_CERT_FILE" # Example "${HOME}/certificates/mine.crt"
export GIT_LFS_SERVER_KEY="YOUR_KEY_FILE" # Example "${HOME}/certificates/mine.key"

# export GIT_LFS_SERVER_TRACE=1 # Uncomment to see the logs

dart pub global activate --source git https://github.com/khoa-io/git-lfs-server.git

dart pub global run git_lfs_server:git_lfs_server_install

# In case you're upgrading
launchctl remove com.khoa-io.git-lfs-server-agent

launchctl load ${HOME}/Library/LaunchAgents/com.khoa-io.git-lfs-server-agent.plist
launchctl start com.khoa-io.git-lfs-server-agent
```

## Linux

Modify the following script to run the server:
```bash
sudo openssl req -x509 -sha256 -nodes -days 2100 -newkey rsa:2048 -keyout "YOUR_CERT_FILE" -out "YOUR_KEY_FILE"
sudo openssl x509 -in YOUR_CERT_FILE -out YOUR_PEM_FILE

git config --global http."YOUR_SERVER_URL.sslverify" false

export GIT_LFS_SERVER_URL="YOUR_SERVER_URL" # Example: "https://localhost:8080"
export GIT_LFS_SERVER_CERT= "YOUR_CERT_FILE" # Example "${HOME}/certificates/mine.crt"
export GIT_LFS_SERVER_KEY="YOUR_KEY_FILE" # Example "${HOME}/certificates/mine.key"

# export GIT_LFS_SERVER_TRACE=1 # Uncomment to see the logs

dart pub global activate --source git https://github.com/khoa-io/git-lfs-server.git

dart pub global run git_lfs_server:git_lfs_server_install

systemctl --user daemon-reload
systemctl --user start git-lfs-server
```

# Usage

- Client: modify `~/.gitconfig`
```
[http "https://address:port"]
	sslverify = false
```

# Developing

Check out [DEVELOPING.md](./DEVELOPING.md)
