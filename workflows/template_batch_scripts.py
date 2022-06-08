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


scripts: list[Script] = []
# Pytorch GAN Zoo batch templates
for dataset, wall_time in [
    ('celeba', '3-00:00:00'),
    ('cifar10', '2-00:00:00'),
    ('dtd', '6-00:00:00')
]:
    data_dir = 'celeba_cropped' if dataset == 'celeba' else dataset
    config = f'config_{data_dir}.json'

    name = f'train_{dataset}.sh'
    path = Path('pytorch_GAN_zoo/batch_scripts/')
    mapping = {
        'nodes': '1',
        'wall_time': wall_time,
        'job_name': f'pytorch_gan_zoo_{dataset}',
        'gpus': '1',
        'inputs': f'{data_dir} {config}',
        'outputs': f'output_networks/{data_dir}_$job_id',
        'container': 'pytorch_GAN_zoo.sif',
        'container_command': (
            f'train.py PGAN -c {config} '
            f'--restart --no_vis -n {data_dir}_$job_id'
        )
    }

    scripts.append(Script(name, path, mapping))

# 3D Very Deep VAE batch templates
for resolution, wall_time in [
    ('32', '02:00:00'),
    ('64', '10:00:00'),
    ('128', '2-00:00:00')
]:
    config = 'VeryDeepVAE_' + 'x'.join(resolution*3) + '.json'

    name = f'train_3d_very_deep_vae_{resolution}.sh'
    path = Path('3d_very_deep_vae/batch_scripts/')
    mapping = {
        'nodes': '1',
        'wall_time': wall_time,
        'job_name': f'3d_very_deep_vae_{resolution}',
        'gpus': '1',
        'inputs': f'data {config}',
        'outputs': 'output_$job_id',
        'container': '3d_very_deep_vae.sif',
        'container_command': (
            'train_vae_model.py '
            '--json_config_file {config} '
            '--nifti_dir ./data --output_dir ./output_$job_id'
        )
    }


# Read batch script template
with open('batch_template.sh', 'r', encoding='utf8') as f:
    template = MyTemplate(f.read())

# Write batch scripts
for script in scripts:
    script_path = script.path / script.name
    with open(script_path, 'w', encoding='utf8') as f:
        f.write(template.safe_substitute(script.mapping))
