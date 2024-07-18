import yaml

yaml_config = """
---
greetings:
    basic: Hello, World!
"""


def get_greeting():
    config = yaml.safe_load(yaml_config)
    return config["greetings"]["basic"]


def main():
    print(get_greeting())


if __name__ == "__main__":
    main()
