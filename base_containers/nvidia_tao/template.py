#!/usr/bin/env python3

import argparse
from string import Template
from typing import NamedTuple


class Spec(NamedTuple):
    name: str


base_name = "nvidia_tao"

tao_spec = {
    "3.21.11": Spec(
        name="v3.21.11-tf1.15.4-py3",
    ),
    "3.21.12": Spec(
        name="v3.21.11-tf1.15.5-py3",
    ),
    "3.21.08": Spec(
        name="v3.21.08-py3",
    ),
}


def fill_template(version: str) -> str:
    """Complete def file template for a particular version"""
    with open(f"{base_name}.def.template", "r", encoding="utf8") as f:
        template = Template(f.read())

    mapping = {"version": tao_spec[version].name}

    return template.substitute(mapping)


def write_def(version: str) -> None:
    """Write a completed def file for a particular version"""
    file_name = f"{base_name}_{version}.def"

    text = fill_template(version)

    with open(file_name, "w", encoding="utf8") as f:
        f.write(text)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Template Nvidia Tao definition files"
    )
    parser.add_argument(
        "version",
        help="Tao version",
        type=str,
        nargs="?",
        choices=["all", "newest"] + list(tao_spec.keys()),
        default="all",
    )

    args = parser.parse_args()

    match (args.version):
        case ("all"):
            for version in tao_spec.keys():
                write_def(version)
        case (_):
            write_def(args.version)


if __name__ == "__main__":
    main()
