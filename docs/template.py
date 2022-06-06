#! /usr/bin/env python3

from pathlib import Path
from string import Template
from typing import NamedTuple


class Script(NamedTuple):
    name: str
    path: Path
    mapping: dict[str, str]


class MyTemplate(Template):
    delimiter = '%'


scripts = [
    Script(
        name='train_celeba.sh',
        path=Path('../workflows/pytorch_GAN_zoo/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '3-00:00:00',
            'job_name': 'pytorch_gan_zoo_celeba',
            'gpus': '1',
            'inputs': 'celeba_cropped config_celeba_cropped.json',
            'outputs': 'output_networks/celeba_cropped_$jobid',
            'container': 'pytorch_GAN_zoo.sif',
            'container_command': (
                'train.py PGAN -c config_celeba_cropped.json '
                '--restart --no_vis -n celeba_cropped_$job_id'
            )
        }
    ),
    Script(
        name='train_cifar10.sh',
        path=Path('../workflows/pytorch_GAN_zoo/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '2-00:00:00',
            'job_name': 'pytorch_gan_zoo_cifar10',
            'gpus': '1',
            'inputs': 'cifar10 config_cifar10.json',
            'outputs': 'output_networks/cifar10_$job_id',
            'container': 'pytorch_GAN_zoo.sif',
            'container_command': (
                'train.py PGAN -c config_cifar10.json '
                '--restart --no_vis -n cifar10_$job_id'
            )
        }
    ),
    Script(
        name='train_dtd.sh',
        path=Path('../workflows/pytorch_GAN_zoo/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '6-00:00:00',
            'job_name': 'pytorch_gan_zoo_dtd',
            'gpus': '1',
            'inputs': 'dtd config_dtd.json',
            'outputs': 'output_networks/dtd_$job_id',
            'container': 'pytorch_GAN_zoo.sif',
            'container_command': (
                'train.py PGAN -c config_dtd.json '
                '--restart --no_vis -n dtd_$job_id'
            )
        }
    ),
    Script(
        name='3d_very_deep_vae_32.sh',
        path=Path('../workflows/3d_very_deep_vae/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '02:00:00',
            'job_name': '3d_very_deep_vae_32',
            'gpus': '1',
            'inputs': 'data VeryDeepVAE_32x32x32.json',
            'outputs': 'output_$job_id',
            'container': '3d_very_deep_vae.sif',
            'container_command': (
                'train_vae_model.py '
                '--json_config_file VeryDeepVAE_32x32x32.json '
                '--nifti_dir ./data --output_dir ./output'
            )
        }
    ),
    Script(
        name='3d_very_deep_vae_64.sh',
        path=Path('../workflows/3d_very_deep_vae/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '10:00:00',
            'job_name': '3d_very_deep_vae_64',
            'gpus': '1',
            'inputs': 'data VeryDeepVAE_64x64x64.json',
            'outputs': 'output_$job_id',
            'container': '3d_very_deep_vae.sif',
            'container_command': (
                'train_vae_model.py '
                '--json_config_file VeryDeepVAE_64x64x64.json '
                '--nifti_dir ./data --output_dir ./output'
            )
        }
    ),
    Script(
        name='3d_very_deep_vae_128.sh',
        path=Path('../workflows/3d_very_deep_vae/batch_scripts/'),
        mapping={
            'nodes': '1',
            'wall_time': '2-00:00:00',
            'job_name': '3d_very_deep_vae_128',
            'gpus': '1',
            'inputs': 'data VeryDeepVAE_128x128x128.json',
            'outputs': 'output_$job_id',
            'container': '3d_very_deep_vae.sif',
            'container_command': (
                'train_vae_model.py '
                '--json_config_file VeryDeepVAE_128x128x128.json '
                '--nifti_dir ./data --output_dir ./output'
            )
        }
    ),
]


with open('batch_template.sh', 'r', encoding='utf8') as f:
    template = MyTemplate(f.read())

for script in scripts:
    script_path = script.path / script.name
    with open(script_path, 'w', encoding='utf8') as f:
        f.write(template.safe_substitute(script.mapping))
