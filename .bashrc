# vim: set ts=4 et sw=4 sts=4 fileencoding=utf-8:
#
################################################################
# Bash Login Script
#
################################################################

declare -r pri_plist="${HOME}/.pathlist0"
declare -r post_plist="${HOME}/.pathlist"
declare -r ssh_agent_file="${HOME}/.ssh_agent"

################################################################
# True if called in interactive shell
#
# Return:
#   0 : if called in an interactive shell
#   1 : not
################################################################

function is_interactive() {
    if [[ "$-" =~ i ]]; then
        return 0
    else
        return 1
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

function read_plist() {
    local filename="$1"

    if [[ ! -e ${filename} ]]; then
        echo ""
    elif $(type cygpath > /dev/null 2>&1); then 
        cat "${filename}" | xargs cygpath | paste -s -d ':' -
    else
        cat "${filename}" | paste -s -d ':' -
    fi
}

################################################################
# Extend PATH env
#
#   Read path list file, and add those pathes to PATH
#
# Globals
#   PATH
# Arguments:
#   None
# Returns:
#   Extended PATH env
################################################################

function extend_path() {
    local path="$1"

    local pri_path=$(read_plist ${pri_plist} 2> /dev/null)
    local post_path=$(read_plist ${post_plist} 2> /dev/null)

    echo "${pri_path}:${path}:${post_path}" | sed \
        -e 's/^://' \
        -e 's/::/:/' \
        -e 's/:$//'
}

################################################################
# Get command name
#
# Arguments:
#   $1 : Process ID
# Returns:
#   None
################################################################

function get_command_name() {
    ps h --pid $1 -o comm
}

################################################################
# Update ssh-agent script
#
# Arguments:
#   $1 : script filename
# Returns:
#   None
################################################################

function update_ssh_agent() {
    local script="$1"

    ssh-agent -s > "${script}" 2>&1
    chmod 600 "${script}"
}

################################################################
# Setup the environment for ssh-agent
#
# Arguments:
#   None
# Returns:
#   None
################################################################

function setup_ssh_agent() {
    local script="${ssh_agent_file}"

    # Return if no ssh-agent command
    if ! $(type ssh-agent > /dev/null 2>&1) \
        || ! $(type ssh-add > /dev/null 2>&1); then
        return 0
    fi

    # Return if ssh-add successfully finishes
    if $(ssh-add > /dev/null 2>&1); then
        return 0
    fi

    if [[ ! -r ${script} ]]; then
        update_ssh_agent ${script}
    fi
    . ${script} > /dev/null 2>&1

    # Return if ssh-add successfully finishes
    if $(ssh-add > /dev/null 2>&1); then
        return 0
    fi

    update_ssh_agent "${script}"
    . ${script} > /dev/null 2>&1
    ssh-add
}

################################################################
# Setup .inputrc
#
# Arguments:
#   $1 : path of .inputrc
# Returns:
#   None
################################################################

function setup_inputrc() {
    local filename="$1"

    cat <<____delimiter____ > "${filename}"
set prefer-visible-bell
____delimiter____
}


################################################################
# Main
################################################################

declare -x PATH=$(extend_path "${PATH}")

# Exit if not interactive shell
if ! $(is_interactive); then
    return 0
fi

################################################################
# Interactive shell
################################################################

setup_inputrc "${HOME}/.inputrc"

declare -x PS1='\[\e[30m\e[47m\]\W\$\[\e[0m\] '

if [[ -r "${HOME}/.shext" ]]; then
    . ${HOME}/.shext
fi
