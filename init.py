#!/usr/bin/env python3

import os
import subprocess
import sys

from shutil import which


def is_tool(name):
    return which(name) is not None


def pip_install(*args):
    subprocess.run(["python3", "-m", "pip", "install", "--user"] + list(args))


def pipenv_install(*args):
    subprocess.run(["pipenv", "install"] + list(args))


def pipenv_run(*args):
    subprocess.run(["pipenv", "run", "python", "-m"] + list(args))


def remove_dir(dir):
    if os.path.exists(dir):
        subprocess.run(["rm", "-rf", dir])


def remove_dirs(*dirs):
    for dir in dirs:
        remove_dir(dir)


def remove_venv():
    subprocess.run(["pipenv", "--rm"])
    remove_dir(".venv")


def display_local_python_path():
    result = subprocess.run(
        ["python3", "-m", "site", "--user-base"],
        capture_output=True,
        text=True,
    )
    print("Add this to your .bashrc or .zshrc")
    print(f"export PATH={result.stdout.strip()}/bin:$PATH")


def set_env_var(key, value):
    os.environ[key] = value


def verify():
    if not is_tool("pipenv"):
        pip_install("--upgrade", "pip")
        pip_install("pipenv")
        display_local_python_path()
        exit(0)


def clean():
    remove_venv()
    remove_dirs(".pytest_cache", "dist")


def setup():
    set_env_var("PIPENV_VENV_IN_PROJECT", "1")
    pipenv_install("--dev")


def install():
    pipenv_install("-e", ".")


def format():
    pipenv_run("black", "src", "tests")


def test():
    pipenv_run("pytest")


def build():
    pipenv_run("build")


if __name__ == "__main__":
    verify()
    clean()
    setup()
    install()
    format()
    test()
    build()
