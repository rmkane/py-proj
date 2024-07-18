import pytest  # type: ignore

from py_project.main import get_greeting


def test_get_greeting():
    assert get_greeting() == "Hello, World!"
