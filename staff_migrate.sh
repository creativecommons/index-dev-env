#!/bin/bash
#
# Notes:
# - This script can only be run by Creative Commons (CC) staff--it requires
#   shell access to the production server
# - If you modify this file, please re-check it with shellcheck
# - '| xargs' is used to trim whitespace
set -o errexit
set -o errtrace
set -o nounset

# shellcheck disable=SC2154
trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

DOCKER_WP_DIR=/var/www/html
DOCKER_WP_URL=http://localhost:8080
# https://en.wikipedia.org/wiki/ANSI_escape_code
E0="$(printf "\e[0m")"        # reset
E1="$(printf "\e[1m")"        # bold
E30="$(printf "\e[30m")"      # black foreground
E31="$(printf "\e[31m")"      # red foreground
E33="$(printf "\e[33m")"      # yellow foreground
E43="$(printf "\e[43m")"      # yellow background
E90="$(printf "\e[90m")"      # bright black (gray) foreground
E92="$(printf "\e[92m")"      # bright green foreground
E97="$(printf "\e[97m")"      # bright white foreground
E100="$(printf "\e[100m")"    # bright black (gray) background
E107="$(printf "\e[107m")"    # bright white background
PROD_SERVER=index__prod
PROD_UPLOADS_DIR=/var/www/index/wp-content/uploads
PROD_WP_DIR=/var/www/index/wp
PROD_WP_HOST=creativecommons.org
PROD_WP_URL="https://${PROD_WP_HOST}"
# NOTE: wordfence does not play nice with Docker. Enabling it results in WP-CLI
#       commands taking approximately 13 times longer (ex. 10.8 seconds
#       instead of 0.8 seconds)
PLUGINS_DEACTIVATE='
google-analytics-for-wordpress
wordfence
'
SCRIPT_NAME="${0##*/}"
# The configure_environment() function sets the following global variables:
CACHE_SQL=''
CACHE_DIR=''
CACHE_UPLOADS_DIR=''
DOCKER_SQL=''
DOCKER_WP_UPLOADS_DIR=''
DOCKER_WP_UPLOADS_TEMP_DIR=''
SCRIPT_ENV=''
SERVER_DOCROOT=''
SERVER_POD=''
SERVER_WP_DIR=''
SERVER_WP_UPLOADS_DIR=''
SERVER_WP_URL=''
# The parse_command() function sets the following global variables:
COMMAND=''


#### FUNCTIONS ################################################################


bold() {
    printf "${E1}%s${E0}\n" "${@}"
}


danger_confirm() {
    local _confirm _i _prompt _rand

    if [[ "${DANGER_BYPASS:-}" == 'i will be careful' ]] \
        && [[ "${SCRIPT_ENV}" == 'docker' ]]
    then
        return
    fi

    printf "${E43}${E30} %-71s$(date '+%T') ${E0}\n" \
        'Confirmation required'
    echo -e "${E33}WARNING:${E0} the '${COMMAND}' command is destructive"
    # Loop until user enters random number
    _rand=${RANDOM}${RANDOM}${RANDOM}
    _rand=${_rand:0:4}
    _prompt="Type the number, ${_rand}, to continue: "
    _i=0
    while read -p "${_prompt}" -r _confirm
    do
        if [[ "${_confirm}" == "${_rand}" ]]
        then
            echo
            return
        fi
        (( _i > 1 )) && error_exit 'invalid confirmation number'
        _i=$(( ++_i ))
    done

    if [[ "${SCRIPT_ENV}" == 'linux' ]] && [[ "${COMMAND}" == 'import' ]]
    then
        sudo_auth
    fi
}


deactivate_plugins() {
    local _bold _plugin _reset
    header 'Deactivate plugins'
    for _plugin in ${PLUGINS_DEACTIVATE}
    do
        if wpcli --no-color --quiet plugin is-active "${_plugin}" &> /dev/null
        then
            wpcli plugin deactivate "${_plugin}"
        else
            no_op "${_plugin} is already inactive"
        fi
    done
    echo
}


delete_wordpress_uploads() {
    local _count
    header 'Delete WordPress uploads'
    if [[ "${SCRIPT_ENV}" == 'docker' ]]
    then
        print_var DOCKER_WP_UPLOADS_DIR
        # (xargs is used to trim whitespace)
        _count=$(docker compose exec index-web \
            sh -c "rm -frv ${DOCKER_WP_UPLOADS_DIR}/* | wc -l | xargs")
    elif [[ "${SCRIPT_ENV}" == 'server' ]]
    then
        print_var SERVER_WP_UPLOADS_DIR
        sudo_auth
        # (xargs is used to trim whitespace)
        _count=$(sudo rm -frv "${SERVER_WP_UPLOADS_DIR}/"* | wc -l | xargs)
    fi
    success "Directories/files removed: ${_count}"
    echo
}


error_exit() {
    # Echo error message and exit with error
    echo -e "${E31}ERROR:${E0} ${*}" 1>&2
    exit 1
}


header() {
    # Print 80 character wide black on white heading
    printf "${E30}${E107} %-71s$(date '+%T') ${E0}\n" "${@}"
}


import_database() {
    local _sql
    header 'Import database'
    if [[ "${SCRIPT_ENV}" == 'docker' ]]
    then
        print_var DOCKER_SQL
        _sql="${DOCKER_SQL}"
    elif [[ "${SCRIPT_ENV}" == 'server' ]]
    then
        print_var CACHE_SQL
        _sql="${CACHE_SQL}"
    fi
    # https://developer.wordpress.org/cli/commands/db/import/
    time wpcli db import "${_sql}"
    echo
}


import_uploads() {
    header 'Import uploads'
    print_var CACHE_UPLOADS_DIR
    if [[ "${SCRIPT_ENV}" == 'docker' ]]
    then
        print_var DOCKER_WP_UPLOADS_DIR
        echo 'Copy cache uploads to docker temp uploads dir'
        docker compose cp "${CACHE_UPLOADS_DIR}" \
            "index-web:${DOCKER_WP_UPLOADS_DIR}.temp" 2>/dev/null
        echo 'Set ownership of temp uploads dir to www-data:wwww-data'
        docker compose exec index-web chown -R www-data:www-data \
            "${DOCKER_WP_UPLOADS_TEMP_DIR}"
        echo 'Replace uploads dir with temp uploads dir'
        docker compose exec index-web mv "${DOCKER_WP_UPLOADS_DIR}" \
            "${DOCKER_WP_UPLOADS_DIR}.old"
        docker compose exec index-web mv "${DOCKER_WP_UPLOADS_DIR}.temp" \
            "${DOCKER_WP_UPLOADS_DIR}"
        docker compose exec index-web rm -rf "${DOCKER_WP_UPLOADS_DIR}.old"
    elif [[ "${SCRIPT_ENV}" == 'server' ]]
    then
        print_var SERVER_WP_UPLOADS_DIR
        sudo_auth
        # (xargs is used to trim whitespace)
        #_count=$(sudo rm -frv "${SERVER_WP_UPLOADS_DIR}/"* | wc -l | xargs)
    fi
    echo
}


no_op() {
    # Print no-op message"
    printf "${E90}no-op: %s${E0}\n" "${@}"
}


optimize_tables() {
    header 'Optimize WordPress database tables'
    wpcli db optimize --color \
        | sed -e'/Table does not support optimize/d' -e'/^status   : OK/d'
    echo
}


parse_command() {
    if [[ -z "${1}" ]]
    then
        error_exit 'a COMMAND is required'
    elif [[ -n "${2:-}" ]]
    then
        error_exit 'only a single COMMAND is allowed'
    fi
    case "${1:-}" in
        -h*|--h*|h*|'-?'|'--?'|'?') COMMAND=help;;
        info) COMMAND=info;;
        pull) COMMAND=pull;;
        import) COMMAND=import;;
        *) error_exit "invalid COMMAND: ${1}";;
    esac
}


post_import_db_update_site_url() {
    local _new_url
    header 'Post-import: Database update: Site URL'
    print_var PROD_WP_URL
    if [[ "${SCRIPT_ENV}" == 'docker' ]]
    then
        _new_url="${DOCKER_WP_URL}"
        print_var DOCKER_WP_URL
    elif [[ "${SCRIPT_ENV}" == 'server' ]]
    then
        _new_url="${SERVER_WP_URL}"
        print_var SERVER_WP_URL
    fi

    _site_url_replacements='
    wp_options:option_value
    wp_postmeta:meta_value
    wp_posts:post_content
    wp_posts:post_excerpt
    wp_posts:guid
    '

    for _replacement in ${_site_url_replacements}
    do
        _table=${_replacement%:*}
        _column=${_replacement#*:}
        echo "${_table}: ${_column}"
        # https://mariadb.com/kb/en/replace-function/
        wpcli db query "
            UPDATE ${_table}
            SET ${_column} = REPLACE(
                ${_column}, '${PROD_WP_URL}', '${_new_url}'
            )
            WHERE ${_column} LIKE '%${PROD_WP_URL}%'
            "
    done
    echo
}

print_key_val() {
    printf "${E97}${E100}%22s${E0} %s\n" "${1}:" "${2}"
}


print_var() {
    print_key_val "${1}" "${!1}"
}


pull_database() {
    header 'Pull WordPress database'
    print_var PROD_SERVER
    print_var PROD_WP_DIR
    print_var CACHE_SQL
    # https://developer.wordpress.org/cli/commands/db/export/
    # https://mariadb.com/kb/en/mariadb-dump/
    ssh "${PROD_SERVER}" \
        wp --path="${PROD_WP_DIR}" --url="${PROD_WP_URL}" db export \
            --exclude_tables=wp_users,wp_usermeta --skip-lock-tables \
            --single-transaction - \
        > "${CACHE_SQL}.tmp"
    mv "${CACHE_SQL}.tmp" "${CACHE_SQL}"
    echo
}


pull_uploads() {
    header 'Pull WordPress uploads files from legacy production server'
    print_var PROD_SERVER
    print_var PROD_UPLOADS_DIR
    print_var CACHE_DIR
    # The rsync options below are ordered to match `man rsync`
    rsync \
        --recursive \
        --links \
        --delete \
        --delete-excluded \
        --partial \
        --prune-empty-dirs \
        --times \
        --exclude .svn \
        --exclude uploads/gravity_forms \
        --exclude uploads/pum \
        --stats \
        --human-readable \
        "${PROD_SERVER}:${PROD_UPLOADS_DIR}" \
        "${CACHE_DIR}/"
    echo
}


rsync_version() {
    print_key_val 'rsync version' \
        "$(rsync --version 2>&1 | awk '/version/ {print $3", "$4" "$5" "$6}')"
}


script_setup() {
    local _cache_dir_filesystem _err _rsync_ver _service _var
    # Determine whether we working in a local macOS dev environment or on a
    # linux server
    case $(uname) in
        Darwin)
            header "Setup environment: local docker development"
            SCRIPT_ENV=docker
            print_var COMMAND
            print_var SCRIPT_ENV
            print_key_val "$(sw_vers --productName) version" \
                "$(sw_vers --productVersion)"
            rsync_version

            # Ensure docker daemon is running
            if [[ ! -S /var/run/docker.sock ]]
            then
                error_exit 'docker daemon is not running'
            fi
            # Ensure services are running
            for _service in index-web index-wpdb
            do
                if ! docker compose exec "${_service}" true 2>/dev/null
                then
                    error_exit "docker ${_service} service is not running"
                fi
            done
            print_key_val 'Docker version' \
                "$(docker --version | sed -e's/^Docker *version *//')"
            print_key_val 'WordPress PHP version' \
                "$(docker compose exec index-web php --version \
                    | awk '/^PHP/ {print $2}')"
            print_key_val 'WordPress version' "$(wpcli core version)"
            print_key_val 'WP-CLI PHP version' \
                "$(wpcli cli info | awk '/^PHP version/ {print $3}')"
            print_key_val 'WP-CLI version' \
                "$(wpcli cli version | cut -d' ' -f2)"
            echo

            # Check execution environment
            if [[ "${PWD##*/}" != 'index-dev-env' ]]
            then
                _err='this script must be executed from a clone of the'
                _err="${_err} index-dev-env repository (this check requires"
                _err="${_err} the current directory to me named"
                _err="${_err} 'index-dev-env')"
                error_exit "${_err}"
            fi

            # Check rsync version
            _rsync_ver=$(rsync --version | grep --fixed-strings version)
            if ! echo "${_rsync_ver}" \
                | grep --quiet --fixed-strings 'protocol version 31'
            then
                _err='older rsync version--please install via `brew install'
                _err="${_err} rsync\` (you may need to open a new terminal"
                _err="${_err} to see new the rsync)"
                error_exit "${_err}"
            fi

            CACHE_DIR=./cache
            mkdir -p "${CACHE_DIR}"


            DOCKER_WP_UPLOADS_DIR="${DOCKER_WP_DIR}/wp-content/uploads"
            _var="${DOCKER_WP_DIR}/wp-content/uploads.temp"
            DOCKER_WP_UPLOADS_TEMP_DIR="${_var}"
            DOCKER_SQL="${DOCKER_WP_DIR}/cache/${PROD_WP_HOST}_export.sql"
            ;;
        Linux)
            header "Setup environment: linux server"
            #######################
            no_op 'unimplemented' #
            exit ##################
            #######################
#            SCRIPT_ENV=server
#            print_var COMMAND
#            print_var SCRIPT_ENV
#            print_key_val 'Debian version' \
#                "$(cat /etc/debian_version) ($(lsb_release -cs))"
#            rsync_version
#            print_key_val 'PHP version' \
#                "$(php --version | awk '/^PHP/ {print $2}')"
#
#
#            SERVER_POD="$(cat /etc/salt/minion_id)"
#            SERVER_POD="${SERVER_POD#*__}"
#            SERVER_POD="${SERVER_POD%__*}"
#
#            SERVER_DOCROOT=/var/www/index
#
#            case "${SERVER_POD}" in
#                'prod')
#                    SERVER_WP_URL=https://creativecommons.org
#                    ;;
#                'stage')
#                    SERVER_WP_URL=https://stage.creativecommons.org
#                    ;;
#            esac
#            SERVER_WP_DIR="${SERVER_DOCROOT}/wp"
#            SERVER_WP_UPLOADS_DIR="${SERVER_DOCROOT}/wp-content/uploads"
#            print_key_val 'WordPress version' "$(wpcli core version)"
#            print_key_val 'WP-CLI version' \
#                "$(wpcli cli version | cut -d' ' -f2)"
#            echo
#
#            CACHE_DIR="/var/www/cache-${USER}"
#            _cache_dir_filesystem=$(df "${CACHE_DIR}" | awk 'END {print $1}')
#            if [[ "${COMMAND}" != 'clean' ]] && [[ ! -d "${CACHE_DIR}" ]]
#            then
#                echo "CACHE_DIR: ${CACHE_DIR}"
#                echo "CACHE_DIR filesystem: ${_cache_dir_filesystem}"
#                echo
#                sudo_auth
#                echo 'Creating CACHE_DIR...'
#                sudo mkdir "${CACHE_DIR}"
#                sudo chown "${USER}:webdev" "${CACHE_DIR}"
#                echo '  done.'
#            fi
            ;;
    esac
    CACHE_UPLOADS_DIR="${CACHE_DIR}/uploads"
    CACHE_SQL="${CACHE_DIR}/${PROD_WP_HOST}_export.sql"
    staff_only_notice
}


show_help() {
    header 'Usage'
    echo "${SCRIPT_NAME} COMMAND"
    echo
    bold 'Commands'
    # help
    echo 'help        print this help message and exit'
    echo 'info        print setup information'
    echo
    # pull
    echo -n 'pull        pull WordPress database and uploads files from'
    echo ' production server'
    echo
    # import
    echo -n 'import      import WordPress database and uploads files'
    echo
    exit
}


staff_only_notice() {
    echo -n 'This script can only be run by Creative Commons (CC) staff--it'
    echo ' requires shell'
    echo 'access to the production server'
    echo
}


success() {
    printf "${E92}Success:${E0} %s\n" "${@}"
}


sudo_auth() {
    if ! sudo -nv 2>/dev/null
    then
        echo "Authorize sudo (update user's cached credentials)"
        sudo -v
        echo
    fi
    sudo -v
}


test_ssh_to_prod() {
    header 'Test SSH connection to production server'
    print_var PROD_SERVER
    if ! ssh "${PROD_SERVER}" true
    then
        error_exit 'unable to connect--verify config and public key'
    else
        success 'connection verified'
        echo
    fi
}


wpcli() {
    case "${SCRIPT_ENV}" in
        'docker')
        # Call WP-CLI with appropriate site arguments via Docker
            docker compose exec index-wpcli \
                /usr/local/bin/wp \
                    --path="${DOCKER_WP_DIR}" \
                    --url="${DOCKER_WP_URL}" \
                    "${@}"
            ;;
        'server')
        # Call WP-CLI with appropriate site arguments
            /usr/local/bin/wp \
                --path="${SERVER_WP_DIR}" \
                --url="${SERVER_WP_URL}" \
                "${@}"
            ;;
    esac
}


#### MAIN #####################################################################

parse_command "${@:-}"
case "${COMMAND}" in
    # the following are sorted by order of operations then lexicographically
    'help') show_help;;
    'info') script_setup;;

    'pull')
        script_setup
        test_ssh_to_prod
        pull_uploads
        pull_database
        ;;

    'import')
        script_setup
        danger_confirm
        delete_wordpress_uploads
        import_uploads
        import_database
        deactivate_plugins
        post_import_db_update_site_url
        optimize_tables
        ;;
esac
