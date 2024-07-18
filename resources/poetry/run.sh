#!/usr/bin/env bash

# ==============================================================================
# Poetry project runner
# ==============================================================================

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/../common/base-run.sh"

# ==============================================================================
# Helper functions
# ==============================================================================

# Setup the virtual environment
setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        $PYTHON -m venv $VENV_DIR
        $VENV_DIR/bin/pip install -U pip setuptools
        $VENV_DIR/bin/pip install poetry
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

# Local install
local_reinstall() {
    poetry install
}

# Local install, if not installed
local_install() {
    module_exists "$PROJECT_NAME" || local_reinstall
}

# Uninstall the package, if installed
local_uninstall() {
    uninstall_package "$PROJECT_NAME"
}

# ==============================================================================
# Command functions
# ==============================================================================

# @command
# @name: freeze
# @desc: Freeze the dependencies
command_freeze() {
    activate_venv && freeze_packages
}

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
    activate_venv && poetry build
}

# @command
# @name: test
# @desc: Run tests using pytest
command_test() {
    export PYTHONPATH=src
    activate_venv && local_install && poetry run pytest
}

# @command
# @name: format
# @desc: Format the code using black
command_format() {
    activate_venv && poetry run black src tests
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
    show_help
}

# ==============================================================================
# Main
# ==============================================================================

# Parse the command line arguments
parse_args() {
    case "$1" in
        freeze)     command_freeze         ;;
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
