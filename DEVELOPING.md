Development Guide
===============================
<!-- TODO: Write this -->

# Build Environment

# Generate authentication code

```bash
protoc --dart_out=grpc:lib/src/generated -Iprotos protos/authentication.proto
```

# Install

```bash
dart pub global activate --source path .
```


```bash
GIT_TRACE=1 GIT_TRANSFER_TRACE=1 GIT_CURL_VERBOSE=1 git clone MIRROR_REPO
```
