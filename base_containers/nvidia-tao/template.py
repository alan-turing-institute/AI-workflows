#!/usr/bin/env python3

import argparse
from string import Template
import sys
from typing import NamedTuple


class Spec(NamedTuple):
    name: str
    # cuda: list[str]
    # vision: str
    # audio: str

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
        # cuda=['11.5', '11.3', '10.2'],
        # vision='0.12.0',
        # audio='0.11.0'
    ),
    '3.21.12': Spec(
        name='v3.21.11-tf1.15.5-py3',
        # cuda=['11.3', '11.1', '10.2'],
        # vision='0.11.3',
        # audio='0.10.2'
    ),
    '3.21.08': Spec(
        name='v3.21.08-py3',
        # cuda=['11.3', '11.1', '10.2'],
        # vision='0.11.2',
        # audio='0.10.1'
    ),
}
# GET THESE FROM SITE
find_links = 'https://download.pytorch.org/whl/torch_stable.html'


# def torch_parameters(torch_version: str, cuda_version: str) -> dict[str, str]:
#     """Derive template parameters for a particular PyTorch version"""

#     # Create CUDA version string. e.g. CUDA 11.3 -> +cu113
#     cuda_string = '+cu' + cuda_version.replace('.', '')

#     spec = torch_spec[torch_version]

#     parameters = {
#         'torch_version': torch_version,
#         'cuda_version': cuda_version,
#         'torch_package_version': torch_version + cuda_string,
#         'torchvision_package_version': spec.vision + cuda_string,
#         'torchaudio_package_version': spec.audio,
#         'find_links': find_links
#     }

#     return parameters


def fill_template(version: str) -> str:
    """Complete def file template for a particular version"""
    with open(f'{NAME}.def.template', 'r', encoding='utf8') as f:
        template = Template(f.read())

    # mapping = torch_parameters(torch_version, cuda_version)
    # print()
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
    # parser.add_argument(
    #     'cuda',
    #     help='CUDA version',
    #     type=str,
    #     nargs='?',
    #     default='all',
    # )

    args = parser.parse_args()

    # match(args.torch, args.cuda):
    #     # Build all def files
    #     case('all', 'all'):
    #         for torch_version, spec in torch_spec.items():
    #             for cuda_version in spec.cuda:
    #                 write_def(torch_version, cuda_version)

    #     # Building all def files for a particular CUDA version is unsupported
    #     case('all', _):
    #         print('Building all def files for a particular CUDA version is'
    #               ' not supported')
    #         sys.exit(1)

    #     # Build all def files for a particular Torch version
    #     case(_, 'all'):
    #         spec = torch_spec[args.torch]
    #         for cuda_version in spec.cuda:
    #             write_def(args.torch, cuda_version)

    #     # Build a single def file for a single Torch & CUDA combination
    #     case(_, _):
    #         spec = torch_spec[args.torch]
    #         if args.cuda not in (supported_versions := spec.cuda):
    #             print(f'Torch {args.torch} does not support CUDA {args.cuda}')
    #             print(
    #                 'Supported CUDA versions: ' + ' '.join(supported_versions)
    #             )
    #             sys.exit(1)

    #         write_def(args.torch, args.cuda)
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
