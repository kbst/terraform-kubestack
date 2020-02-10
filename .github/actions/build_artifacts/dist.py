#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir
from shutil import copytree, make_archive, rmtree

from jinja2 import Environment, FileSystemLoader

SRCDIR = 'quickstart/src'
DISTDIR = 'quickstart/_dist'

# Use tag as version, fallback to commit sha
version = environ.get('GITHUB_SHA')
gitref = environ.get('GITHUB_REF')
if gitref.startswith('refs/tags/'):
    version = gitref.replace('refs/tags/', '')

# Clean DISTDIR
if isdir(DISTDIR):
    rmtree(DISTDIR)
mkdir(DISTDIR)

# Copy configuration
configurations = [n for n in listdir(f'{SRCDIR}/configurations')
                  if not n.startswith('_')]

for configuration in configurations:
    configuration_name = f'infra-quickstart-{configuration}'
    configuration_src = f'{SRCDIR}/configurations/{configuration}'
    configuration_dist = f'{DISTDIR}/{configuration_name}'
    archive_name = f'{configuration_dist}-{version}'
    manifests_src = f'{SRCDIR}/manifests'
    manifests_dist = f'{configuration_dist}/manifests'
    cicd_src = f'{SRCDIR}/ci-cd'
    cicd_dist = f'{configuration_dist}/ci-cd'

    copytree(configuration_src, configuration_dist)
    copytree(manifests_src, manifests_dist)
    copytree(cicd_src, cicd_dist)

    # Replace templated variable with version in clusters.tf
    jinja = Environment(loader=FileSystemLoader(configuration_dist))
    template = jinja.get_template('clusters.tf')
    data = template.render(version=version)

    with open(f'{configuration_dist}/clusters.tf', 'w') as f:
        f.write(data)
        # always include newline at end of file
        f.write('\n')

    make_archive(archive_name, 'zip', f'{DISTDIR}', configuration_name)
