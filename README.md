A simple git-lfs server implementation
===============================

# Overview
<!-- TODO: Write this -->
According to the [Git LFS documentation](https://github.com/git-lfs/git-lfs/tree/main/docs/api):
> The Git LFS client uses an HTTPS server to coordinate fetching and storing large binary objects separately from a Git server.

This is a simple git-lfs server implementation which can work with existing Git repositories via SSH.
So, if your Git server does not support Git LFS already, you can use this implementation.
In case your Git repository is a mirror of another (which supports Git LFS), you can use this implementation as well.

# Environment Variables

- `GIT_LFS_SERVER_URL`: The URL of the `git-lfs-server`
- `GIT_LFS_EXPIRES_IN`: The time in seconds after which the server will expire the object.
- `GIT_LFS_SERVER_CERT`: The path to the certificate file.
- `GIT_LFS_SERVER_KEY`: The path to the key file.

# Dependencies

- pwgen

# Usage

Generate a key pair: `openssl req -x509 -sha256 -nodes -days 2100 -newkey rsa:2048 -keyout mine.key -out mine.crt`
Convert the key pair to a PEM file: `openssl x509 -in mine.crt -out mine.pem`
# References

- [Git LFS API](https://github.com/git-lfs/git-lfs/tree/main/docs/api)
