#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create secp384r1 wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    else
        CONFIG_FILE="getssl-dns01-secp384.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_line --partial "Public Key Algorithm: id-ecPublicKey"
    cleanup_environment
}


@test "Create dual certificates using DNS-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        CONFIG_FILE="getssl-dns01-dual-rsa-ecdsa.cfg"
    else
        CONFIG_FILE="getssl-dns01-dual-rsa-ecdsa-old-nginx.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    check_certificates
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt" ]

    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_line --partial "Public Key Algorithm: rsaEncryption"

    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt"
    assert_line --partial "Public Key Algorithm: id-ecPublicKey"

    cleanup_environment
}
