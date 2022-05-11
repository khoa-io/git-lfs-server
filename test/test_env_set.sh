export GIT_LFS_SERVER_TRACE=true
export GIT_LFS_SERVER_URL="https://localhost:8080"
export GIT_LFS_SERVER_CERT="${HOME}/certificates/mine.crt"
export GIT_LFS_SERVER_KEY="${HOME}/certificates/mine.key"
export GIT_LFS_EXPIRES_IN=3600

dart test test/test_env_set.dart --reporter=expanded --chain-stack-traces
