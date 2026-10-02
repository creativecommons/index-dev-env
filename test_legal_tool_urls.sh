#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o nounset

# shellcheck disable=SC2154
trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

# https://en.wikipedia.org/wiki/ANSI_escape_code
E0="$(printf "\e[0m")"        # reset
E30="$(printf "\e[30m")"      # foreground: black
E31="$(printf "\e[31m")"      # foreground: red
E35="$(printf "\e[35m")"      # foreground: magenta
E36="$(printf "\e[36m")"      # foreground: cyan
E92="$(printf "\e[92m")"      # foreground: bright green
E94="$(printf "\e[94m")"      # foreground: bright blue
E107="$(printf "\e[107m")"    # background: bright white
declare -i FAILURES=0
TARGET_HOST="${1:-http://localhost:8080}"

NO_INDEX_DIRS='
/licenses/sa/2.0/
/licenses/nd/2.0/
/licenses/nd-nc/2.0/
/licenses/nc/2.0/
/licenses/nc-sa/2.0/
/cc-legal-tools/
'

ENSURE_LOWERCASE='
/LiCeNsEs/By/4.0/DeEd.En
/lIcEnSeS/bY/2.0/uK/
'

ALT_LANG_CODES='
/licenses/by/3.0/es/legalcode.es-es
/licenses/by/3.0/es/legalcode.oci
/licenses/by/3.0/rs/legalcode.sr-cyrl
/licenses/by/3.0/rs/legalcode.sr-latin
/licenses/by/4.0/deed.zh
/licenses/by/4.0/deed.zh_cn
/licenses/by/4.0/deed.zh_tw
'

ISSUE236='
/licenses/by-nc-nd/1.0/deed.INVALID
/licenses/by-nd-nc/1.0/deed.INVALID
/licenses/sampling/1.0/br/deed.apy
/licenses/sampling+/1.0/deed.INVALID
/licenses/by-nc-sa/2.0/deed.INVALID
/licenses/by-nc/2.0/be/deed.wa
/licenses/by-nd/2.1/deed.INVALID
/licenses/by-sa/2.1/jp/deed.ryn
/licenses/by/2.5/deed.INVALID
/licenses/by/2.5/ar/deed.gn
/licenses/by/3.0/deed.INVALID
/licenses/by/3.0/am/deed.hy
/licenses/by/3.0/es/deed.ast
/licenses/by/4.0/deed.INVALID
/licenses/by/4.0/deed.mi
'

# sorted with: sort -t'/' -V -k6 -k7 -k5
ISSUE444='
/licenses/by-nc-sa/1.0/il/
/licenses/by-nc/1.0/il/
/licenses/by-nd-nc/1.0/il/
/licenses/by-nd/1.0/il/
/licenses/by-sa/1.0/il/
/licenses/by/1.0/il/
/licenses/by-nc-nd/2.0/uk/
/licenses/by-nc-sa/2.0/uk/
/licenses/by-nc/2.0/uk/
/licenses/by-nd/2.0/uk/
/licenses/by-sa/2.0/uk/
/licenses/by/2.0/uk/
/licenses/by-nc-nd/2.0/za/
/licenses/by-nc-sa/2.0/za/
/licenses/by-nc/2.0/za/
/licenses/by-nd/2.0/za/
/licenses/by-sa/2.0/za/
/licenses/by/2.0/za/
/licenses/by-nc-nd/2.5/il/
/licenses/by-nc-sa/2.5/il/
/licenses/by-nc/2.5/il/
/licenses/by-nd/2.5/il/
/licenses/by-sa/2.5/il/
/licenses/by/2.5/il/
/licenses/by-nc-nd/2.5/in/
/licenses/by-nc-sa/2.5/in/
/licenses/by-nc/2.5/in/
/licenses/by-nd/2.5/in/
/licenses/by-sa/2.5/in/
/licenses/by/2.5/in/
/licenses/by-nc-nd/2.5/mk/
/licenses/by-nc-sa/2.5/mk/
/licenses/by-nc/2.5/mk/
/licenses/by-nd/2.5/mk/
/licenses/by-sa/2.5/mk/
/licenses/by/2.5/mk/
/licenses/by-nc-nd/2.5/scotland/
/licenses/by-nc-sa/2.5/scotland/
/licenses/by-nc/2.5/scotland/
/licenses/by-nd/2.5/scotland/
/licenses/by-sa/2.5/scotland/
/licenses/by/2.5/scotland/
/licenses/by-nc-nd/2.5/za/
/licenses/by-nc-sa/2.5/za/
/licenses/by-nc/2.5/za/
/licenses/by-nd/2.5/za/
/licenses/by-sa/2.5/za/
/licenses/by/2.5/za/
/licenses/by-nc-nd/3.0/am/
/licenses/by-nc-sa/3.0/am/
/licenses/by-nc/3.0/am/
/licenses/by-nd/3.0/am/
/licenses/by-sa/3.0/am/
/licenses/by/3.0/am/
/licenses/by-nc-nd/3.0/ge/
/licenses/by-nc-sa/3.0/ge/
/licenses/by-nc/3.0/ge/
/licenses/by-nd/3.0/ge/
/licenses/by-sa/3.0/ge/
/licenses/by/3.0/ge/
/licenses/by-nc-nd/3.0/hk/
/licenses/by-nc-sa/3.0/hk/
/licenses/by-nc/3.0/hk/
/licenses/by-nd/3.0/hk/
/licenses/by-sa/3.0/hk/
/licenses/by/3.0/hk/
/licenses/by-nc-nd/3.0/ie/
/licenses/by-nc-sa/3.0/ie/
/licenses/by-nc/3.0/ie/
/licenses/by-nd/3.0/ie/
/licenses/by-sa/3.0/ie/
/licenses/by/3.0/ie/
/licenses/by-nc-nd/3.0/sg/
/licenses/by-nc-sa/3.0/sg/
/licenses/by-nc/3.0/sg/
/licenses/by-nd/3.0/sg/
/licenses/by-sa/3.0/sg/
/licenses/by/3.0/sg/
/licenses/by-nc-nd/3.0/th/
/licenses/by-nc-sa/3.0/th/
/licenses/by-nc/3.0/th/
/licenses/by-nd/3.0/th/
/licenses/by-sa/3.0/th/
/licenses/by/3.0/th/
/licenses/by-nc-nd/3.0/vn/
/licenses/by-nc-sa/3.0/vn/
/licenses/by-nc/3.0/vn/
/licenses/by-nd/3.0/vn/
/licenses/by-sa/3.0/vn/
/licenses/by/3.0/vn/
/licenses/by-nc-nd/3.0/za/
/licenses/by-nc-sa/3.0/za/
/licenses/by-nc/3.0/za/
/licenses/by-nd/3.0/za/
/licenses/by-sa/3.0/za/
/licenses/by/3.0/za/
'

COMPATIBILITY='
/licenses/publicdomain/
/licenses/nc-nd/1.0/
/licenses/mark/1.0/
/licenses/by-nc-nd/1.0/
/license/by/4.0/
/license/
/license
/licences/by-nc/4.0/
/licences/
/licences
/licence/by-nc-sa/4.0/
/licence/
/licence
'

ISSUE1433='
/licenses/list.it/by-nc/2.0/it/by-nc-sa/2.5/dk/sa/2.0/jp/by/4.0/legalcode.sk
/licenses/list.en/invalid/
'

# Found via:
# ./wpcli.sh db query 'SELECT post_status, post_name, guid FROM wp_posts WHERE guid LIKE "http://localhost:8080/license%";'
WP_COLLISION_RISK='
/license-status/upcoming/2007/08/hong-kong/
/license-status/upcoming/2007/08/thailand/
'
# Present, but not currently found in production
# /license-status/upcoming/weblog/2009/11/20/weblog/19275
# /license-status/upcoming/weblog/2009/11/20/weblog/19275

DEFAULT_VER_CURRENT='
/publicdomain/zero/
/publicdomain/zero
/publicdomain/mark/
/licenses/by/
/licenses/by-sa/
/licenses/by-nd/
/licenses/by-nd-nc/
/licenses/by-nc/
/licenses/by-nc-sa/
/licenses/by-nc-nd
'
DEFAULT_VER_RETIRED='
/publicdomain/certification/
/licenses/sampling/
/licenses/sampling+/
/licenses/sa/
/licenses/nd-nc/
/licenses/nc/
/licenses/nc-sampling+/
/licenses/nc-sa/
/licenses/devnations/
/licenses/devnations
'

#### FUNCTIONS ################################################################


print_header() {
    # Print 80 character wide black on bright white heading with time
    printf "${E30}${E107}# %-69s$(date '+%T') ${E0}\n" "${@}"
}


test_expect_found() {
    # Success is 200, 301=>200, or 302=>200
    local _code _header _http _location _redirect _result _path _paths _url
    _header="${1}"
    _paths="${2}"
    print_header "Test expect found: ${_header}"
    for _path in ${_paths}
    do
        _url="${TARGET_HOST}${_path}"
        _result=$(http --headers --pretty none "${_url}")
        _http=$(echo "${_result}" \
            | awk '/^HTTP/ {print $1}' \
            | tr -d '[:cntrl:]')
        _code=$(echo "${_result}" \
            | awk '/^HTTP/ {print $2}' \
            | tr -d '[:cntrl:]')
        _redirect=''
        case "${_code}" in
            200) echo -n "${E92}";;
            301) echo -n "${E36}"; _redirect="${E36}";;
            302) echo -n "${E94}"; _redirect="${E94}";;
              *) echo -n "${E31}"; FAILURES=$((FAILURES+1));;
        esac
        printf "%s  %s  %s${E0}\n" "${_http}" "${_code}" "${_url}"
        if [[ -n "${_redirect}" ]]
        then
            _result=$(http --all --follow --headers --pretty none \
                "${_url}")
            _location=$(echo "${_result}" \
                | awk '/^Location:/ {print $2}' \
                | tail -n1 \
                | tr -d '[:cntrl:]')
            _code=$(echo "${_result}" \
                | awk '/^HTTP/ {print $2}' \
                | tail -n1 \
                | tr -d '[:cntrl:]')
            echo -n "${_redirect}>>>>>>>>${E0}"
            case "${_code}" in
                200) echo -n "${E92}";;
                  *) echo -n "${E31}"; FAILURES=$((FAILURES+1));;
            esac
            printf "  %s  %s${E0}\n" "${_code}" "${_location}"
        fi
    done
    echo
}


test_expect_code() {
    local _code _expected_code _header _http _result _path _paths _url
    _expected_code="${1}"
    _header="${2}"
    _paths="${3}"
    print_header "Test expect code ${_expected_code}: ${_header}"
    for _path in ${_paths}
    do
        _url="${TARGET_HOST}${_path}"
        _result=$(http --headers --pretty none "${_url}")
        _http=$(echo "${_result}" \
            | awk '/^HTTP/ {print $1}' \
            | tr -d '[:cntrl:]')
        _code=$(echo "${_result}" \
            | awk '/^HTTP/ {print $2}' \
            | tr -d '[:cntrl:]')
        case "${_code}" in
            "${_expected_code}") echo -n "${E92}";;
            *) echo -n "${E31}"; FAILURES=$((FAILURES+1));;
        esac
        printf "%s  %s  %s${E0}\n" "${_http}" "${_code}" "${_url}"
    done
    echo
}


#### MAIN #####################################################################


if [[ "${TARGET_HOST}" == 'http://localhost:8080' ]]
then
    print_header 'Restarting Docker service'
    docker compose restart index-web
    echo
fi

test_expect_code 403 'Directories without index' "${NO_INDEX_DIRS}"

test_expect_found 'Ensure lowercase' "${ENSURE_LOWERCASE}"

test_expect_found 'Alternate language codes' "${ALT_LANG_CODES}"

echo 'https://github.com/creativecommons/cc-legal-tools-app/issues/444'
test_expect_found 'Working default language index.html' "${ISSUE444}"

echo 'https://github.com/creativecommons/cc-legal-tools-app/issues/236'
test_expect_found 'Fail gracefully when deed not found' "${ISSUE236}"

echo 'https://github.com/creativecommons/creativecommons.org/issues/1431'
test_expect_found 'Compatibility' "${COMPATIBILITY}"

test_expect_found 'Potential WordPress collisions' "${WP_COLLISION_RISK}"

echo 'https://github.com/creativecommons/tech-support/issues/1433'
test_expect_code 404 'Rewrite requires full valid paths' "${ISSUE1433}"

echo 'https://github.com/creativecommons/cc-legal-tools-app/issues/571'
test_expect_found 'Default versions - current' "${DEFAULT_VER_CURRENT}"

echo 'https://github.com/creativecommons/cc-legal-tools-app/issues/571'
test_expect_found 'Default versions - retired' "${DEFAULT_VER_RETIRED}"

if (( FAILURES > 0 ))
then
    echo
    echo "${E31}Failures: ${FAILURES}${E0}" 1>&2
    exit 1
fi
