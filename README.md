A simple Git LFS server implementation in Dart
===============================

[![CI](https://github.com/khoa-io/git-lfs-server/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/khoa-io/git-lfs-server/actions/workflows/ci.yml)
[![Release](https://github.com/khoa-io/git-lfs-server/actions/workflows/release.yml/badge.svg)](https://github.com/khoa-io/git-lfs-server/actions/workflows/release.yml)
# Overview

Git LFS client (`git-lfs` or `git lfs` command) requires a dedicated LFS-content server (not the Git server!) in order to download/upload binary files. There will be an issue if you try to use a mirror of a Git repo with LFS-enabled: [git-lfs#1338](https://github.com/git-lfs/git-lfs/issues/1338). This Git LFS server implementation solves that problem.

There are other [implementations](https://github.com/git-lfs/git-lfs/wiki/Implementations) that you can look for if you're not working with Git mirrors.

# Quick Reference

* Maintained by:
[Khoa](https://github.com/khoa-io)

* Documentation:
[git-lfs-server Wiki](https://github.com/khoa-io/git-lfs-server/wiki).

* Where to get help:
[git-lfs-server Discussions](https://github.com/khoa-io/git-lfs-server/discussions/categories/q-a)

# Benefit

There are two important reasons to set up a Git server for mirroring with LFS-enabled:
- To save bandwidth on the connection to the remote server, especially if the repositories are big.
- Team members don't have access to the remote server, but your Git server can.

# Limitations

- Only _download_ operation is supported. You cannot _upload_ binary files.
- LFS contents in the mirror are not fetched automatically by this tool.

# Quick Start

For the sake of simplicity, I have created a Docker Hub repository with the images ready to use. Assumed that you have the same problem as in [git-lfs#1338](https://github.com/git-lfs/git-lfs/issues/1338) (There's a picture in it if you like graphical presentation). Although, for a smoothly experience, I would add some more details:
- Mirrors will be accessible via SSH, i.e., you can do `git clone git@GIT_SERVER:MIRROR_REPO.git`, or `git clone ssh://git@GIT_SERVER:PORT/MIRROR_REPO.git`
- Self-signed certificate: we need a `.key` file, a `.crt` file, a `.pem` file. Follow this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04#step-2-creating-the-ssl-certificate) to create one.
- You will need some automation to fetch latest Git references and LFS contents from the _far_ repositories, in case the _far_ repositories are newer than the mirrors.
- Far remote is LFS-enabled.
- Near remote has Docker installed.

If all requirements are satisfied, let us proceed step-by-step
1. Pull the image: `docker pull khoa10/amz-git-mirroring:latest`
2. Create a volume to store the certificate:
```bash
# There must be a folder named `certificates` with 3 files: `git-lfs-server.key`, `git-lfs-server.cert`, `git-lfs-server.pem`
docker volume create --name git-lfs-server-certs
docker run --rm -v $PWD:/source -v git-lfs-server-certs:/dest -w /source alpine cp -r certificates /dest
```
3. With your mirrors are located at `$MIRRORING_PATH`, create the container:
```bash
docker run \
--detach \
--name git-mirroring-with-lfs-enabled \
--mount type=bind,src=${MIRRORING_PATH},dst=/source \
--mount type=volume,src=git-lfs-server-certs,dst=/etc/git-lfs-server/certificates \
-p 8443:8443 \
-p 2022:22 \
khoa10/amz-git-mirroring
```

Now, your Git server is available at `ssh://git@<NEAR_REMOTE>:2022` and the LFS server is available at `https://<NEAR_REMOTE>:8443`.
Because we're using self-signed certificate, Git client must either ignore TLS verification or trust the certificate you created.
To ignore TLS verification:
```bash
git config --global http.https://<NEAR_REMOTE>:8443.sslverify false
```
For better experience, client should configure to download from _near_ and push to _far_:
```bash
git config --global url.ssh://git@<NEAR_REMOTE>:2022.insteadOf ssh://git@<FAR_REMOTE>
git config --global url.ssh://git@<FAR_REMOTE>.pushInsteadOf ssh://git@<NEAR_REMOTE>:2022
```

# License

MIT license
