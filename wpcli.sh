#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

source .env
WEB_WP_DIR=/var/www/html
WEB_WP_URL=http://127.0.0.1:8000


#### FUNCTIONS ################################################################


wpcli() {
    docker compose run --rm \
        --env WP_ADMIN_USER=${WP_ADMIN_USER} \
        --env WP_ADMIN_PASS=${WP_ADMIN_PASS} \
        --env WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL} \
        wordpress-cli \
        /usr/local/bin/wp --path=${WEB_WP_DIR} --url=${WEB_WP_URL} "${@}"
}


#### MAIN #####################################################################


wpcli "${@}"
