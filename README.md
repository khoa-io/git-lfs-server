A simple Git LFS server implementation in Dart
===============================

# Overview

> [Git Large File Storage (LFS)](https://git-lfs.github.com) is a free, open-source extension that replaces large files with text pointers inside Git and stores the contents of those files on a remote server.
> -- [GitHub Training & Guides](https://youtu.be/uLR1RNqJ1Mw)

Git LFS protocol requires a Git server that supports LFS, and a Git LFS client. There is only one official open-source [LFS client](https://github.com/git-lfs/git-lfs.git). But there are several [LFS server implementations](https://github.com/git-lfs/git-lfs/wiki/Implementations). This implementation provides a simple solution that works with Git mirrors.

## An example that this implementation can be used for
Your team has a (LFS) repo at GitHub (which supports LFS). That repo contains very large file(s) so you mirror it to your local machine to share with your team to save bandwidth. Your teammates can clone/fetch/pull from your local machine instead of GitHub. The problem is `git lfs` always fails to fetch the file. You run `git lfs fetch --all` on the mirror but it doesn't solve the problem. That's because your machine doesn't have a Git LFS server. So this implementation now comes in handy. Just install, run it, then your teammates can clone/fetch/pull from your local machine, with LFS. Note that this implementation only supports _download_ operations, i.e. `git lfs fetch`. You **cannot** upload files, i.e. `git lfs push`.

# Installing
## Dependencies

- [Dart SDK](https://dart.dev/get-dart): `git-lfs-server` is a Dart package so it needs this to execute.
  - Ubuntu: `sudo snap install flutter`
  - MacOS: `brew install flutter`
- [Git LFS](https://github.com/khoa-io/git-lfs-server.git): keep mirrors' large files up-to-date.
  - Ubuntu: `sudo apt-get install git-lfs`
  - MacOS: `brew install git-lfs`

## macOS

Modify the following script to run the server:
```bash
openssl req -x509 -sha256 -nodes -days 2100 -newkey rsa:2048 -keyout "YOUR_CERT_FILE" -out "YOUR_KEY_FILE"

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

# Usage

## Configure HTTPS

- Server:
    - Generate a key pair: `openssl req -x509 -sha256 -nodes -days 2100 -newkey rsa:2048 -keyout mine.key -out mine.crt`
    - Convert the key pair to a PEM file: `openssl x509 -in mine.crt -out mine.pem`
- Client: modify `~/.gitconfig`
```
[http "https://address:port"]
	sslverify = false
```

## Environment Variables
The `git-lfs-server` needs some environment variables in order to run:
- `GIT_LFS_SERVER_URL`: The URL of the `git-lfs-server`, for example: `http://localhost:8080`.
- `GIT_LFS_EXPIRES_IN`: The number of seconds after which the server will expire the file object, for example `86400`.
- `GIT_LFS_SERVER_CERT`: The path to the certificate file, for example `mine.crt`.
- `GIT_LFS_SERVER_KEY`: The path to the key file, for example `mine.key`.
- `GIT_LFS_AUTHENTICATE_TRACE`: Controls logging of `git-lfs-authenticate` command.
- `GIT_LFS_SERVER_TRACE`: Controls logging of `git-lfs-server` command.

# Developing

Check out [DEVELOPING.md](./DEVELOPING.md)
