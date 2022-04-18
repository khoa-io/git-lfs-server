A simple git-lfs server implementation
===============================

# Overview
<!-- TODO: Write this -->
According to the [Git LFS documentation](https://github.com/git-lfs/git-lfs/tree/main/docs/api):
> The Git LFS client uses an HTTPS server to coordinate fetching and storing large binary objects separately from a Git server.

This is a simple git-lfs server implementation which can work with existing Git repositories via SSH.
So, if your Git server does not support Git LFS already, you can use this implementation.
In case your Git repository is a mirror of another (which supports Git LFS), you can use this implementation as well.

# References

- [Git LFS API](https://github.com/git-lfs/git-lfs/tree/main/docs/api)
