# setuptools

## Setup

Update pip and install the virtual environment module.

```shell
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade venv
```

## Determine requirements

```shell
python3 -m venv .venv
source .venv/bin/activate
pip install $package
pip freeze
```
