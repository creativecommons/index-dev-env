#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

# shellcheck disable=SC2154
trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

# shellcheck disable=SC1091
source .env
WEB_WP_DIR=/var/www/html
WEB_WP_URL=http://localhost:8080


#### FUNCTIONS ################################################################


wpcli() {
    # Call WP-CLI with appropriate site arguments via Docker
    #
    # docker compose run redirects the stderr of any invoked executables to
    # stdout. The only messages that will appear on stderr are issued by
    # docker compose run itself. This appears to be an undocumented "feature":
    # https://docs.docker.com/engine/reference/commandline/compose_run/
    #
    # The "2>/dev/null" below silences the messages from docker compose run.
    # For example, the output like the following will not be visible:
    #     [+] Creating 2/0
    #      ✔ Container cc-wordpress-db  Running                          0.0s
    #      ✔ Container cc-web           Running                          0.0s
    docker compose run --rm \
        --env WP_ADMIN_USER="${WP_ADMIN_USER}" \
        --env WP_ADMIN_PASS="${WP_ADMIN_PASS}" \
        --env WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}" \
        wordpress-cli \
            /usr/local/bin/wp --path="${WEB_WP_DIR}" --url="${WEB_WP_URL}" \
            "${@}" 2>/dev/null
}


#### MAIN #####################################################################


wpcli "${@}"
