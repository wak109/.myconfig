# vim: set ts=4 et sw=4 sts=4 fileencoding=utf-8:
#
################################################################
# Bash Login Script
#
################################################################


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

function get_unix_path() {
    if [[ "$1" =~ ^[a-zA-Z]: ]]; then
        echo $1 | sed \
            -e 's/\\/\//g' \
            -e 's/^\([a-zA-Z]\):/\/cygdrive\/\1/'
    else
        echo $1
    fi
}

################################################################
# Convert pathname list file to PATH format
#
# Arguments:
#   $1 : filename
# Returns:
#   String in PATH format
#   Empty string if file doesn't exist
################################################################

function read_pathlist() {
    local filename="$1"

    if [[ ! -e ${filename} ]]; then
        echo ""
    fi

    while read path; do
        echo $(get_unix_path "${path}")
    done < "${filename}" | paste -s -d ':' -
}

################################################################
# get PATH env
#
# Globals
#   PATH
# Arguments:
#   None
# Returns:
#   None
################################################################

function get_path_env() {
    local pathlist=$(read_pathlist ${HOME}/.pathlist 2> /dev/null)
    local pathlist0=$(read_pathlist ${HOME}/.pathlist0 2> /dev/null)

    echo "${pathlist0}:${PATH}:${pathlist}" | sed \
        -e 's/^://' \
        -e 's/::/:/' \
        -e 's/:$//'
}


################################################################
# Main

declare -x PATH=$(get_path_env)

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
