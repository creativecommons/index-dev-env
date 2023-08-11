#!/bin/bash
#
# Notes:
# - docker compose run redirects the stderr of any invoked executables to
#   stdout. The only messages that will appear on stderr are issued by docker
#   compose run itself. This appears to be an undocumented "feature":
#   https://docs.docker.com/engine/reference/commandline/compose_run/
#
#   The "2>/dev/null" below silences the messages from docker compose run.
#   For example, the output like the following will not be visible:
#       [+] Creating 2/0
#        ✔ Container cc-wordpress-db  Running                             0.0s
#        ✔ Container cc-web           Running                             0.0s
#
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
ACTIVATE_PLUGINS='
acf-menu-chooser
advanced-custom-fields
akismet
classic-editor
redirection
tablepress
wordpress-importer
'
ACTIVATE_THEMES='
vocabulary-theme
'
WEB_WP_DIR=/var/www/html
WEB_WP_URL=http://localhost:8080


#### FUNCTIONS ################################################################


activate_plugins() {
    local _plugin
    header 'Activate WordPress plugins'
    for _plugin in ${ACTIVATE_PLUGINS}
    do
        if wpcli --no-color --quiet plugin is-active "${_plugin}" &> /dev/null
        then
            echo "no-op: ${_plugin} is already active"
        else
            wpcli plugin activate "${_plugin}"
        fi
    done
    echo
}


activate_themes() {
    local _theme
    header 'Activate WordPress themes'
    for _theme in ${ACTIVATE_THEMES}
    do
        if wpcli --no-color --quiet theme is-active "${_theme}" &> /dev/null
        then
            echo "no-op: ${_theme} is already active"
        else
            wpcli theme activate "${_theme}"
        fi
    done
    echo
}

composer_install() {
    header 'Composer install'
    docker compose run --rm composer install 2>/dev/null
    echo
}

enable_permalinks() {
    header 'Enable post name permalinks'
    if wpcli --no-color --quiet rewrite list 2> /dev/null \
        | grep -qF 'page/?([0-9]{1,})/?$'
    then
        echo 'no-op: rewrite rules exist'
    else
        wpcli rewrite structure --hard '/%postname%'
    fi
    echo
}


error_exit() {
    # Echo error message and exit with error
    echo -e "\033[31mERROR:\033[0m ${*}" 1>&2
    exit 1
}


header() {
    # Print 80 character wide black on white heading
    printf "\033[1m\033[7m %-80s\033[0m\n" "${@}"
}


install_wordpress() {
    local _err
    header 'Install WordPress'
    if [[ -n "${WP_ADMIN_EMAIL}" ]] && [[ -n "${WP_ADMIN_EMAIL}" ]] \
        && [[ -n "${WP_ADMIN_EMAIL}" ]]
    then
        echo "WP_ADMIN_EMAIL: ${WP_ADMIN_EMAIL}"
        echo "WP_ADMIN_USER:  ${WP_ADMIN_USER}"
        echo "WP_ADMIN_PASS:  ${WP_ADMIN_PASS}"
    else
        _err='The following variables must be set in .env (see .env.example):'
        _err="${_err} WP_ADMIN_EMAIL, WP_ADMIN_USER, WP_ADMIN_PASS"
        error_exit "${_err}"
    fi
    echo
    if wpcli --no-color --quiet core is-installed &> /dev/null
    then
        echo 'no-op: already installed'
    else
        wpcli core install \
            --title='CreativeCommons.org Local Dev' \
            --admin_email="${WP_ADMIN_EMAIL}" \
            --admin_user="${WP_ADMIN_USER}" \
            --admin_password="${WP_ADMIN_PASS}" \
            --skip-email
    fi
    echo
}


utils_info() {
    header 'Utilities info'
    docker compose run --rm composer --version 2>/dev/null
    wpcli --info
    echo
}

wordpress_update_db() {
    header 'Update WordPress database'
    wpcli core update-db
    echo
}


wordpress_db_check() {
    header 'Check WordPress database'
    wpcli db check
    echo
}


wordpress_status() {
    header 'Show maintenance mode status to expose any PHP Warnings'
    wpcli maintenance-mode status
    echo
}


wpcli() {
    # Call WP-CLI with appropriate site arguments via Docker
    docker compose run --rm \
        --env WP_ADMIN_USER="${WP_ADMIN_USER}" \
        --env WP_ADMIN_PASS="${WP_ADMIN_PASS}" \
        --env WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}" \
        wordpress-cli \
            /usr/local/bin/wp --path="${WEB_WP_DIR}" --url="${WEB_WP_URL}" \
            "${@}" 2>/dev/null
}


#### MAIN #####################################################################

utils_info
composer_install
install_wordpress
activate_plugins
activate_themes
enable_permalinks
wordpress_update_db
wordpress_db_check
wordpress_status
