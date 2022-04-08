#!/usr/bin/env python3

import argparse
from string import Template
import sys

torch = {
    '1.9': {
        '10.2': {
            'torch_version': '1.9.0+cu102',
            'torchvision_version': '0.10.0+cu102',
            'torchaudio_version': '0.9.0',
            'find_links': 'https://download.pytorch.org/whl/torch_stable.html'
        },
        '11.1': {
            'torch_version': '1.9.0+cu111',
            'torchvision_version': '0.10.0+cu111',
            'torchaudio_version': '0.9.0',
            'find_links': 'https://download.pytorch.org/whl/torch_stable.html'
        }
    },
    '1.10': {
        '11.3': {
            'torch_version': '1.10.2+cu113',
            'torchvision_version': '0.11.3+cu113',
            'torchaudio_version': '0.10.2+cu113',
            'find_links': (
                'https://download.pytorch.org/whl/cu113/torch_stable.html'
            )
        }
    }
}


def render(torch_version: str, cuda_version: str) -> str:
    with open('pytorch_cu.def.template', 'r', encoding='utf8') as f:
        template = Template(f.read())

    return template.substitute(**torch[torch_version][cuda_version])


def write_def(torch_version: str, cuda_version: str) -> None:
    file_name = f'pytorch_{torch_version}_cu_{cuda_version}.def'

    text = render(torch_version, cuda_version)
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
        choices=['all'] + list(torch.keys()),
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
            for torch_version, cuda in torch.items():
                for cuda_version in cuda.keys():
                    write_def(torch_version, cuda_version)
        # Building all def files for a particular CUDA version is unsupported
        case('all', _):
            print('Building all def files for a particular CUDA version is'
                  ' not supported')
            sys.exit(1)
        # Build all def files for a particular Torch version
        case(_, 'all'):
            cuda = torch[args.torch]

            for cuda_version in cuda.keys():
                write_def(args.torch, cuda_version)
        # Build a single def file for a single Torch & CUDA combination
        case(_, _):
            if args.cuda not in (supported_versions :=
                                 torch[args.torch].keys()):
                print(f'Torch {args.torch} does not support CUDA {args.cuda}')
                print('Supported CUDA versions:'
                      f' {" ".join(supported_versions)}')
                sys.exit(1)

            write_def(args.torch, args.cuda)


if __name__ == '__main__':
    main()
