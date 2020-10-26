#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

# TODO test certificate revoke
# TODO test secp385
# TODO test dual rsa
# TODO test copy to multiple locations
# TODO test items in SANS
# TODO test domain with wildcard in SANS
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
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check CHECK_REMOTE works for wildcard certificates" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    run ${CODE_DIR}/getssl "*.$GETSSL_HOST"
    assert_success
    assert_line --partial "certificate is valid for more than"
    check_output_for_errors
}


@test "Force renewal of wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    run ${CODE_DIR}/getssl -f "*.$GETSSL_HOST"
    assert_success
    refute_line --partial "certificate is valid for more than"
    check_output_for_errors
}


@test "Check renewal of near-expiration wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    echo "RENEW_ALLOW=2000" >> "${INSTALL_DIR}/.getssl/*.${GETSSL_HOST}/getssl.cfg"

    run ${CODE_DIR}/getssl "*.$GETSSL_HOST"
    assert_success
    refute_line --partial "certificate is valid for more than"
    check_output_for_errors
    cleanup_environment
}
