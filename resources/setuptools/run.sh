#!/usr/bin/env bash

# ==============================================================================
# Setuptools project runner
# ==============================================================================

# Constants
PYTHON=python3
VENV_DIR=.venv

# ==============================================================================
# Utility functions
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

# ==============================================================================
# Configuration
# ==============================================================================

# Extract project information
PROJECT_NAME=$(toml_value name)
PROJECT_SCRIPT=$(toml_key_for_value_pattern '[a-zA-Z0-9_.]+:[a-zA-Z0-9_]+')

# Determine the package name
PACKAGE=$(echo "$PROJECT_NAME" | tr '-' '_')

# ==============================================================================
# Utility functions
# ==============================================================================

# Check if a module is installed
module_exists() {
    $PYTHON -m pip show "$1" > /dev/null 2>&1
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

# ==============================================================================
# Helper functions
# ==============================================================================

# Setup the virtual environment
setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        $PYTHON -m venv "$VENV_DIR"
        $VENV_DIR/bin/pip install -U pip setuptools
    fi
}

# Activate the virtual environment
activate_venv() {
    setup_venv
    if ! source "$VENV_DIR/bin/activate"; then
        echo "Failed to activate virtual environment" >&2
        exit 1
    fi
}

# Install requirements by file
install_requirements() {
    local file="$1"
    [ -f "$file" ] && $PYTHON -m pip install -r "$file" > /dev/null 2>&1
}

# Install requirements
install_required() {
    install_requirements requirements.txt
}

# Install build requirements
install_required_build() {
    install_requirements requirements-build.txt
}

# Install development requirements
install_required_dev() {
    install_requirements requirements-dev.txt
}

# Install test requirements
install_required_test() {
    install_requirements requirements-test.txt
}

# Local install
local_reinstall() {
    $PYTHON -m pip install -e . > /dev/null 2>&1
}

# Local install, if not installed
local_install() {
    module_exists "$PACKAGE" || local_reinstall
}

# Uninstall the package, if installed
local_uninstall() {
    module_exists "$PACKAGE" && \
        $PYTHON -m pip uninstall -y "$PACKAGE" > /dev/null 2>&1 || \
        echo "Package not installed."
}

# ==============================================================================
# Command functions
# ==============================================================================

# @command
# @name: install
# @desc: Install the package in editable mode
command_install() {
    activate_venv && local_reinstall
}

# @command
# @name: uninstall
# @desc: Uninstall the package
command_uninstall() {
    activate_venv && local_uninstall
}

# @command
# @name: build
# @desc: Build the package
command_build() {
    activate_venv && install_required_build && $PYTHON -m build
}

# @command
# @name: test
# @desc: Run tests using pytest
command_test() {
    export PYTHONPATH=src
    activate_venv && install_required_test && $PYTHON -m pytest
}

# @command
# @name: format
# @desc: Format the code using black
command_format() {
    activate_venv && install_required_dev && $PYTHON -m black src tests
}

# @command
# @name: clean
# @desc: Remove build artifacts
command_clean() {
    echo "Removing generated files..."
    rm -rf .pytest_cache .venv build dist
    remove_dirs_recursive "*.egg-info" __pycache__
}

# @command
# @name: exec
# @desc: Execute the script
command_exec() {
    if [ -z "$PROJECT_SCRIPT" ]; then
        echo "Project script not set or found in pyproject.toml"
        exit 1
    fi
    activate_venv && local_install && $PROJECT_SCRIPT "$@"
}

# @command
# @name: help
# @desc: Show this help message
command_help() {
    cat << EOF
$(usage)

Available commands:
$(get_commands)
EOF
}

# ==============================================================================
# Main
# ==============================================================================

# Parse the command line arguments
parse_args() {
    case "$1" in
        install)    command_install        ;;
        uninstall)  command_uninstall      ;;
        build)      command_build          ;;
        test)       command_test           ;;
        format)     command_format         ;;
        clean)      command_clean          ;;
        exec)       command_exec "${@:2}"  ;;
        help)       command_help           ;;
        *)          usage && exit 1        ;;
    esac
}

# shellcheck disable=SC2015
[ $# -eq 0 ] && { usage; exit 1; } || parse_args "$1"
