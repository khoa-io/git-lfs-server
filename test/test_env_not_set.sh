unset GIT_LFS_SERVER_TRACE
unset GIT_LFS_SERVER_URL
unset GIT_LFS_SERVER_CERT
unset GIT_LFS_SERVER_KEY
unset GIT_LFS_EXPIRES_IN

dart test test/test_env_not_set.dart --reporter=expanded --chain-stack-traces
