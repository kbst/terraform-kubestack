#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir, exists, join
from shutil import copytree, make_archive, rmtree

from jinja2 import Environment, FileSystemLoader

SRCDIR = 'quickstart/src'
DISTDIR = 'quickstart/_dist'


def replace_template(dist_path, file_name, context):
    # Replace templated variable with version in clusters.tf
    jinja = Environment(loader=FileSystemLoader(dist_path))
    template = jinja.get_template(file_name)
    data = template.render(context)

    with open(f'{dist_path}/{file_name}', 'w') as f:
        f.write(data)
        # always include newline at end of file
        f.write('\n')


# Use tag as version, fallback to commit sha
version = environ.get('GITHUB_SHA')
# Non tagged images go to a different image repository
image_name = 'kubestack/framework-dev'

gitref = environ.get('GITHUB_REF')
if gitref.startswith('refs/tags/'):
    version = gitref.replace('refs/tags/', '')
    # Tagged releases go to main image repository
    image_name = 'kubestack/framework'

# Clean DISTDIR
if isdir(DISTDIR):
    rmtree(DISTDIR)
mkdir(DISTDIR)

# Copy configuration
configurations = [n for n in listdir(f'{SRCDIR}/configurations')
                  if not n.startswith('_')]

for configuration in configurations:
    configuration_name = f'kubestack-starter-{configuration}'
    configuration_src = f'{SRCDIR}/configurations/{configuration}'
    configuration_dist = f'{DISTDIR}/{configuration_name}'
    archive_name = f'{configuration_dist}-{version}'
    manifests_src = f'{SRCDIR}/manifests'
    manifests_dist = f'{configuration_dist}/manifests'

    copytree(configuration_src, configuration_dist)
    copytree(manifests_src, manifests_dist)

    # Replace templated version variable in clusters.tf
    replace_template(configuration_dist, 'clusters.tf', {'version': version})

    # Replace templated variables in Dockerfiles
    dockerfiles = ['Dockerfile', 'Dockerfile.loc']
    for dockerfile in dockerfiles:
        if exists(join(configuration_dist, dockerfile)):
            replace_template(configuration_dist,
                             dockerfile,
                             {'image_name': image_name, 'image_tag': version})

    # Replace default ingress reference
    replace_template(manifests_dist,
                     'overlays/apps/kustomization.yaml',
                     {'configuration': configuration})

    make_archive(archive_name, 'zip', f'{DISTDIR}', configuration_name)
