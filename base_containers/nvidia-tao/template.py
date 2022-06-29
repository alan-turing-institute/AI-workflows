#!/usr/bin/env python3

import argparse
from string import Template
import sys
from typing import NamedTuple


class Spec(NamedTuple):
    name: str

NAME = "nvidia-tao"

# See https://pytorch.org/get-started/previous-versions/
# https://download.pytorch.org/whl/torch_stable.html
# e.g.
#   https download.pytorch.org/whl/torch_stable.html | grep 'torch-1.11.*cu11'

# Supported PyTorch version specifications
# For each version of torch the corresponding CUDA versions, torchvision
# version and torchaudio version is declared
tao_spec = {
    '3.21.11': Spec(
        name='v3.21.11-tf1.15.4-py3',
    ),
    '3.21.12': Spec(
        name='v3.21.11-tf1.15.5-py3',
    ),
    '3.21.08': Spec(
        name='v3.21.08-py3',
    ),
}


def fill_template(version: str) -> str:
    """Complete def file template for a particular version"""
    with open(f'{NAME}.def.template', 'r', encoding='utf8') as f:
        template = Template(f.read())

    mapping = {'version': version}

    return template.substitute(mapping)


def write_def(spec: Spec) -> None:
    """Write a completed def file for a particular version"""
    file_name = f'{NAME}_{spec[0]}.def'

    text = fill_template(spec[1].name)

    with open(file_name, 'w', encoding='utf8') as f:
        f.write(text)


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Template Nvidia-tao definition files'
    )
    parser.add_argument(
        'version',
        help='Tao version',
        type=str,
        nargs='?',
        choices=['all', 'newest'] + list(tao_spec.keys()),
        default='all'
    )

    args = parser.parse_args()

    match(args.version):
        case('all'):
            for version in tao_spec.items():
                write_def(version)
        case('newest'):
            print('not supported')
        case(_):
            write_def((args.version, tao_spec[args.version]))


if __name__ == '__main__':
    main()
