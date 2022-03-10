#!/usr/bin/env python3

import argparse
from string import Template

CUDA = {
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
    },
    '11.3': {
        'torch_version': '1.10.2+cu113',
        'torchvision_version': '0.11.3+cu113',
        'torchaudio_version': '0.10.2+cu113',
        'find_links': (
            'https://download.pytorch.org/whl/cu113/torch_stable.html'
        )
    }
}


def render(cuda_version: str) -> str:
    with open('pytorch_cu.def.template', 'r', encoding='utf8') as f:
        template = Template(f.read())

    return template.substitute(**CUDA[cuda_version])


def write_def(cuda_version: str, text: str) -> None:
    file_name = f'pytorch_cu_{cuda_version}.def'
    with open(file_name, 'w', encoding='utf8') as f:
        f.write(text)


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Template Pytorch definition files'
    )
    parser.add_argument(
        'cuda',
        help='CUDA version',
        type=str,
        choices=['all'] + list(CUDA.keys())
    )

    args = parser.parse_args()

    if args.cuda == 'all':
        for cuda_version in CUDA.keys():
            write_def(cuda_version, render(cuda_version))
    else:
        write_def(args.cuda, render(args.cuda))


if __name__ == '__main__':
    main()
