A simple Git LFS server implementation in Dart
===============================

# Overview

> [Git Large File Storage (LFS)](https://git-lfs.github.com) is a free, open-source extension that replaces large files with text pointers inside Git and stores the contents of those files on a remote server.
> -- [GitHub Training & Guides](https://youtu.be/uLR1RNqJ1Mw)

Git LFS protocol requires a Git server that supports LFS, and a Git LFS client. There is only one official open-source [LFS client](https://github.com/git-lfs/git-lfs.git). But there are several [LFS server implementations](https://github.com/git-lfs/git-lfs/wiki/Implementations). This implementation provides a simple solution that works with Git mirrors. See [git-lfs issue #1338](https://github.com/git-lfs/git-lfs/issues/1338).

# An example that this implementation can be used for
It is recommended that you check out [Git Mirroring with LFS](https://github.com/khoa-io/git-lfs-server/wiki/Git-Mirroring-with-LFS).
This wiki page provides more details on advantages, limitations, as well as installation steps.

For more information about installing and using this, please read our [wiki](https://github.com/khoa-io/git-lfs-server/wiki).
