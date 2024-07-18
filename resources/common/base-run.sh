#!/usr/bin/env bash

# ==============================================================================
# Extraction functions
# ==============================================================================

# Extract a value from the pyproject.toml file
toml_value() {
  [ -f pyproject.toml ] && \
    awk -F'= ' "/^$1/ {gsub(/\"/, \"\", \$2); print \$2}" pyproject.toml
}

# Extract a key for a given value pattern
toml_key_for_value_pattern() {
  [ -f pyproject.toml ] && \
    awk -F'=' "/$1/ {gsub(/ /, \"\", \$1); print \$1}" pyproject.toml
}

# Determine the package name
package_name() {
    local project_name="$1"
    echo "$project_name" | tr '-' '_'
}

# ==============================================================================
# Configuration
# ==============================================================================

# Constants
PYTHON=python3
VENV_DIR=.venv

PROJECT_NAME=$(toml_value name)
PROJECT_SCRIPT=$(toml_key_for_value_pattern '[a-zA-Z0-9_.]+:[a-zA-Z0-9_]+')

# Determine the package name
PACKAGE=$(package_name "$PROJECT_NAME")

# ==============================================================================
# Utility functions
# ==============================================================================

# Freeze packages
freeze_packages() {
    $PYTHON -m pip freeze > requirements-tmp.txt
}

# Check if a module is installed
module_exists() {
    $PYTHON -m pip show "$1" > /dev/null 2>&1
}

# Uninstall package
uninstall_package() {
    module_exists "$PROJECT_NAME" && \
        $PYTHON -m pip uninstall -y "$PROJECT_NAME" > /dev/null 2>&1 || \
        echo "Package not installed."
}

# Remove directories recursively
remove_dirs_recursive() {
    for dir in "$@"; do find . -type d -name "$dir" -exec rm -rf {} + ; done
}

# Show usage message
usage() {
    echo "Usage: $0 {$(get_commands | awk '{print $1}' | tr '\n' '|' | sed 's/|$//')}"
}

# Get the list of available commands
get_commands() {
    grep -E "^# @name:|^# @desc:" "$0" | awk '
        /^# @name:/ { name=$3 }
        /^# @desc:/ { desc=substr($0, index($0,$3)); printf "  %-10s %s\n", name, desc }
    '
}

# Show command help
show_help() {
    cat << EOF
$(usage)

Available commands:
$(get_commands)
EOF
}
