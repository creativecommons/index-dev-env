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

# https://en.wikipedia.org/wiki/ANSI_escape_code
E0="$(printf "\033[0m")"        # reset
E1="$(printf "\033[1m")"        # bold
E30="$(printf "\033[30m")"      # black foreground
E31="$(printf "\033[31m")"      # red foreground
E33="$(printf "\033[33m")"      # yellow foreground
E36="$(printf "\033[36m")"      # cyan foreground
E90="$(printf "\033[90m")"      # bright black (gray) foreground
E97="$(printf "\033[97m")"      # bright white foreground
E100="$(printf "\033[100m")"    # bright black (gray) background
E107="$(printf "\033[107m")"    # bright white background
OPT_DATE_FORMAT=Y-m-d
OPT_TIME_FORMAT='H:i'
OPT_DEFAULT_COMMENT_STATUS=closed
PLUGINS_ACTIVATE='
acf-menu-chooser
advanced-custom-fields
akismet
classic-editor
redirection
tablepress
wordpress-importer
'
THEMES_ACTIVATE='
vocabulary-theme
'
THEMES_REMOVE='
twentytwentyone
twentytwentytwo
'
WEB_WP_DIR=/var/www/html
WEB_WP_URL=http://localhost:8080


#### FUNCTIONS ################################################################

format_list() {
    local _header_match _header_replace
    _h="${E97}${E100}"
    _header_match='(^name *)  (status *)  (update *)  (version)'
    _header_replace="${_h}\1${E0}  ${_h}\2${E0}  ${_h}\3${E0}  ${_h}\4${E0}"
    sed -u -E \
        -e"s/${_header_match}/${_header_replace}/" \
        -e"s/(^.* inactive .*$)/${E90}\1${E0}/" \
        -e"s/( active .*)( available )/\1${E33}\2${E0}/" \
        -e"s/( active .*)( none )/\1${E90}\2${E0}/"
}


activate_plugins() {
    local _bold _plugin _reset
    header 'Activate plugins'
    for _plugin in ${PLUGINS_ACTIVATE}
    do
        if wpcli --no-color --quiet plugin is-active "${_plugin}" &> /dev/null
        then
            no_op "${_plugin} is already active"
        else
            wpcli plugin activate "${_plugin}"
        fi
    done
    wpcli plugin list --format=csv \
        | column -s',' -t \
        | format_list
    echo
}


activate_themes() {
    local _theme
    header 'Activate themes'
    for _theme in ${THEMES_ACTIVATE}
    do
        if wpcli --no-color --quiet theme is-active "${_theme}" &> /dev/null
        then
            no_op "${_theme} is already active"
        else
            wpcli theme activate "${_theme}"
        fi
    done
    wpcli theme list --format=csv \
        | column -s',' -t \
        | format_list
    echo
}


composer_install() {
    header 'Composer install'
    docker compose run --rm index-composer install --ansi 2>&1 \
        | sed \
            -e'/Container.*Running$/d' \
            -e'/is looking for funding./d' \
            -e'/Use the .composer fund. command/d'
    echo
}


container_print() {
    printf "${E36}%19s${E0} %s\n" "${1}" "${2}"
}


database_check() {
    header 'Check database'
    wpcli db check --color \
        | sed -e'/^wordpress[.]wp_.*OK$/d'
    echo
}


database_optimize() {
    header 'Optimize database'
    # Only show errors and summary
    wpcli db optimize --color \
        | sed \
            -e'/^wordpress[.]wp_/d' \
            -e'/Table does not support optimize/d' \
            -e'/^status   : OK/d'
    echo
}


database_update() {
    header 'Update database'
    wpcli core update-db
    echo
}


enable_permalinks() {
    header 'Enable post name permalinks'
    if wpcli --no-color --quiet rewrite list 2> /dev/null \
        | grep -qF 'page/?([0-9]{1,})/?$'
    then
        no_op 'rewrite rules exist'
    else
        wpcli rewrite structure --hard '/%postname%'
    fi
    echo
}


environment_info() {
    local _key _val IFS
    header 'Container information'

    # index-composer
    printf "${E1}%s${E0} - %s\n" \
        'index-composer' 'A Dependency Manager for PHP'
    container_print 'Composer version' \
        "$(docker compose run --rm index-composer \
            --no-ansi --version 2>/dev/null | sed -e's/^Composer version //')"
    echo

    # index-web
    printf "${E1}%s${E0} - %s\n" 'index-web' \
        'Web server (WordPress and static HTML components)'
    print_var WEB_WP_URL
    print_var WEB_WP_DIR
    container_print 'WordPress version:' "$(wpcli core version)"
    echo

    # index-wpcli
    printf "${E1}%s${E0} - %s\n" \
        'index-wpcli' 'The command line interface for WordPress'
    IFS=$'\n'
    for _line in $(wpcli --info | sort)
    do
        _key="${_line%%:*}"
        # '| xargs' is used to trim whitespace
        _val="$( echo "${_line#*:}" | xargs)"
        [[ -n "${_val}" ]] || continue
        [[ "${_key}" =~ ^WP-CLI ]] || continue
        container_print "${_key}:" "${_val}"
    done
    echo
}


error_exit() {
    # Echo error message and exit with error
    echo -e "${E31}ERROR:${E0} ${*}" 1>&2
    exit 1
}


header() {
    # Print 80 character wide black on white heading with time
    printf "${E30}${E107} %-71s$(date '+%T') ${E0}\n" "${@}"
}


install_wordpress() {
    local _err
    header 'Install WordPress'
    if [[ -n "${WP_ADMIN_EMAIL}" ]] && [[ -n "${WP_ADMIN_EMAIL}" ]] \
        && [[ -n "${WP_ADMIN_EMAIL}" ]]
    then
        print_var WP_ADMIN_EMAIL
        print_var WP_ADMIN_USER
        print_var WP_ADMIN_PASS
    else
        _err='The following variables must be set in .env (see .env.example):'
        _err="${_err} WP_ADMIN_EMAIL, WP_ADMIN_USER, WP_ADMIN_PASS"
        error_exit "${_err}"
    fi
    echo
    if wpcli --no-color --quiet core is-installed &> /dev/null
    then
        no_op 'already installed'
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


no_op() {
    # Print no-op message"
    printf "${E90}no-op: %s${E0}\n" "${@}"
}


print_var() {
    printf "${E36}%19s${E0} %s\n" "${1}:" "${!1}"
}


remove_themes() {
    local _theme
    header 'Remove extraneous themes'
    for _theme in ${THEMES_REMOVE}
    do
        if ! wpcli --no-color --quiet theme is-installed "${_theme}" \
            > /dev/null
        then
            no_op "${_theme} is not installed"
        else
            wpcli theme delete "${_theme}"
        fi
    done
    echo
}


update_options() {
    local _date_format _default_comment_status _noop _time_format
    header 'Update options'

    _date_format=$(wpcli option get date_format)
    if [[ "${OPT_DATE_FORMAT}" != "${_date_format}" ]]
    then
        echo "Update date_format: ${OPT_DATE_FORMAT}"
        wpcli option update date_format "${OPT_DATE_FORMAT}"
    else
        no_op "date_format: ${OPT_DATE_FORMAT}"
    fi

    _default_comment_status=$(wpcli option get default_comment_status)
    if [[ "${OPT_DEFAULT_COMMENT_STATUS}" != "${_default_comment_status}" ]]
    then
        echo "Update default_comment_status: ${OPT_DEFAULT_COMMENT_STATUS}"
        wpcli option update default_comment_status \
            "${OPT_DEFAULT_COMMENT_STATUS}"
    else
        _noop="default_comment_status: ${OPT_DEFAULT_COMMENT_STATUS}"
        no_op "${_noop}"
    fi

    _time_format=$(wpcli option get time_format)
    if [[ "${OPT_TIME_FORMAT}" != "${_time_format}" ]]
    then
        echo "Update time_format: ${OPT_TIME_FORMAT}"
        wpcli option update time_format "${OPT_TIME_FORMAT}"
    else
        no_op "time_format: ${OPT_TIME_FORMAT}"
    fi

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
        index-wpcli \
            /usr/local/bin/wp --path="${WEB_WP_DIR}" --url="${WEB_WP_URL}" \
            "${@}" 2>/dev/null
}


#### MAIN #####################################################################

environment_info
composer_install
install_wordpress
update_options
remove_themes
activate_plugins
activate_themes
enable_permalinks
database_update
database_optimize
database_check
wordpress_status
