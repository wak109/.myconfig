# vim: set ts=4 et sw=4 sts=4 fileencoding=utf-8:
#
################################################################
# Bash Login Script
#
################################################################

if $(type cygpath > /dev/null 2>&1); then
    declare -r HAS_CYGPATH=true
else
    declare -r HAS_CYGPATH=false
fi

################################################################
# True if called in interactive shell
#
# Return:
#   0 : if called in an interactive shell
#   1 : not
################################################################

function is_interactive() {
    if [[ "$-" =~ 'i' ]]; then
        return 0
    else
        return 1
    fi
}


################################################################
# Convert Windows path to Cygwin path without space
#
# Arguments:
#   $1 : pathname
# Return:
#   Unix format path name
################################################################

function convert_winpath() {
    local mixed=$(cygpath -m -s "$1" 2> /dev/null)

    if [[ "${mixed}" != "" && "${mixed}" != "$1" ]]; then
        echo $(cygpath -u "${mixed}")
    else
        echo "$1"
    fi
}


################################################################
# Convert pathname list file to PATH format
#
# Arguments:
#   $1 : filename
# Returns:
#   String in PATH format
################################################################

function get_path_list() {
    local filename="$1"

    if [[ ! -e ${filename} ]]; then
        echo ""
    fi

    while read path; do
        if ${HAS_CYGPATH}; then
            echo $(convert_winpath "${path}")
        else
            echo ${path}
        fi
    done < "${filename}" | paste -s -d ':' -
}

################################################################
# Set PATH env
#
# Globals
#   PATH
# Arguments:
#   None
# Returns:
#   None
################################################################

function set_path_env() {
    local pathlist=$(get_path_list ${HOME}/.pathlist 2> /dev/null)
    local pathlist0=$(get_path_list ${HOME}/.pathlist0 2> /dev/null)

    if [[ ! -e "${pathlist0}" ]]; then
        PATH="${pathlist0}:${PATH}"
    fi
    if [[ ! -e "${pathlist}" ]]; then
        PATH="${PATH}:${pathlist}"
    fi
}


################################################################
# Main

set_path_env

# Exit if not interactive shell
if ! $(is_interactive); then
    return 0
fi

################################################################
# Interactive shell

declare -x PS1='\[\e[30m\e[47m\]\W\$\[\e[0m\] '

if [[ -r "${HOME}/.shext" ]]; then
    . ${HOME}/.shext
fi
