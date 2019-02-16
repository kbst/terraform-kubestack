#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir
from shutil import copytree, make_archive, rmtree

SRCDIR = 'src'
DISTDIR = '_dist'

# Get name and version
version = environ.get('TAG_NAME', None)
if not version:
    version = environ.get('BRANCH_NAME', 'master')

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

    make_archive(archive_name, 'zip', f'{DISTDIR}', configuration_name)
