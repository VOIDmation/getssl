#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

# TODO test certificate on host doesn't need renewing
# TODO test certificate on host does need renewing
# TODO test certificate revoke
# TODO generate error if wildcard cert and http-01 verification


@test "Create wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-wildcard.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment

    init_getssl
    create_certificate -d
    assert_success
    check_output_for_errors
}
