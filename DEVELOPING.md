Development Guide [WIP]
===============================
<!-- TODO: Write this -->

# Build Environment

# Generate authentication code

```bash
protoc --dart_out=grpc:lib/src/generated -Iprotos protos/authentication.proto
```

# Test

## Server

```bash
dart pub global activate --source path .
```

## Client

```bash
GIT_TRACE=1 GIT_TRANSFER_TRACE=1 GIT_CURL_VERBOSE=1 git clone MIRROR_REPO
```

```bash
bash test/test_git_lfs_authenticate.sh MIRROR_REPO download
bash test/test_client_batch.sh URL TOKEN
bash test/test_client_download.sh URL TOKEN
```

# References

- [Git LFS API](https://github.com/git-lfs/git-lfs/tree/main/docs/api)
