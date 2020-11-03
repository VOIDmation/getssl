#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Check can create certificate for wildcard domain as arg and non-wildcard in SANS" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-dns01-wildcard-and-sans.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_output --partial "DNS:${GETSSL_CMD_HOST}, DNS:a.${GETSSL_HOST}"
}


@test "Check can create certificate for non-wildcard domain as arg and wildcard in SANS" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-dns01-wildcard-in-sans.cfg"
    fi

    GETSSL_CMD_HOST="${GETSSL_HOST}"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_output --partial "DNS:${GETSSL_CMD_HOST}, DNS:*.${GETSSL_HOST}"
}
