#!/usr/bin/env python3

import argparse
from string import Template
import sys

# See https://pytorch.org/get-started/previous-versions/
# https://download.pytorch.org/whl/torch_stable.html
# e.g.
#   https download.pytorch.org/whl/torch_stable.html | grep 'torch-1.11.*cu11'

# Supported PyTorch version specifications
# For each version of torch the corresponding CUDA versions, torchvision
# version and torchaudio version is declared
torch_spec = {
    '1.11.0': {
        'cuda': ['11.5', '11.3', '10.2'],
        'vision': '0.12.0',
        'audio': '0.11.0'
    },
    '1.10.2': {
        'cuda': ['11.3', '11.1', '10.2'],
        'vision': '0.11.3',
        'audio': '0.10.2'
    },
    '1.10.1': {
        'cuda': ['11.3', '11.1', '10.2'],
        'vision': '0.11.2',
        'audio': '0.10.1'
    },
    '1.10.0': {
        'cuda': ['11.3', '11.1', '10.2'],
        'vision': '0.11.0',
        'audio': '0.10.0'
    },
    '1.9.1': {
        'cuda': ['11.1', '10.2'],
        'vision': '0.10.1',
        'audio': '0.9.1'
    },
    '1.9.0': {
        'cuda': ['11.1', '10.2'],
        'vision': '0.10.0',
        'audio': '0.9.0'
    },
}

find_links = 'https://download.pytorch.org/whl/torch_stable.html'


def torch_parameters(torch_version: str, cuda_version: str) -> dict[str, str]:
    """Derive template parameters for a particular PyTorch version"""

    # Create CUDA version string. e.g. CUDA 11.3 -> +cu113
    cuda_string = '+cu' + cuda_version.replace('.', '')

    parameters = {
        'torch_version': torch_version + cuda_string,
        'torchvision_version': (torch_spec[torch_version]['vision'] +
                                cuda_string),
        'torchaudio_version': torch_spec[torch_version]['audio'],
        'find_links': find_links
    }

    return parameters


def fill_template(torch_version: str, cuda_version: str) -> str:
    """Complete def file template for a particular PyTorch version"""
    with open('pytorch_cu.def.template', 'r', encoding='utf8') as f:
        template = Template(f.read())

    mapping = torch_parameters(torch_version, cuda_version)

    return template.substitute(mapping)


def write_def(torch_version: str, cuda_version: str) -> None:
    """Write a completed def file for a particular PyTorch version"""
    file_name = f'pytorch_{torch_version}_cu_{cuda_version}.def'

    text = fill_template(torch_version, cuda_version)

    with open(file_name, 'w', encoding='utf8') as f:
        f.write(text)


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Template Pytorch definition files'
    )
    parser.add_argument(
        'torch',
        help='Torch version',
        type=str,
        nargs='?',
        choices=['all'] + list(torch_spec.keys()),
        default='all'
    )
    parser.add_argument(
        'cuda',
        help='CUDA version',
        type=str,
        nargs='?',
        default='all',
    )

    args = parser.parse_args()

    match (args.torch, args.cuda):
        # Build all def files
        case('all', 'all'):
            for torch_version, spec in torch_spec.items():
                for cuda_version in spec['cuda']:
                    write_def(torch_version, cuda_version)

        # Building all def files for a particular CUDA version is unsupported
        case('all', _):
            print('Building all def files for a particular CUDA version is'
                  ' not supported')
            sys.exit(1)

        # Build all def files for a particular Torch version
        case(_, 'all'):
            spec = torch_spec[args.torch]
            for cuda_version in spec['cuda']:
                write_def(args.torch, cuda_version)

        # Build a single def file for a single Torch & CUDA combination
        case(_, _):
            if args.cuda not in (supported_versions :=
                                 torch_spec[args.torch]['cuda']):
                print(f'Torch {args.torch} does not support CUDA {args.cuda}')
                print(
                    'Supported CUDA versions: ' + ' '.join(supported_versions)
                )
                sys.exit(1)

            write_def(args.torch, args.cuda)


if __name__ == '__main__':
    main()
