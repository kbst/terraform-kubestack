#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir, exists, join
from shutil import copytree, make_archive, rmtree
from sys import argv, exit

from jinja2 import Environment, FileSystemLoader

SRCDIR = '../src'
DISTDIR = '../_dist'
ARTIFACT_PREFIX = 'kubestack-starter-'


def replace_template(dist_path, file_name, context):
    # Replace templated variable with version in clusters.tf
    jinja = Environment(loader=FileSystemLoader(dist_path))
    template = jinja.get_template(file_name)
    data = template.render(context)

    with open(f'{dist_path}/{file_name}', 'w') as f:
        f.write(data)
        # always include newline at end of file
        f.write('\n')


def dist(version, image_name, configuration):
    configuration_src = f'{SRCDIR}/configurations/{configuration}'
    configuration_dist = f'{DISTDIR}/{ARTIFACT_PREFIX}{configuration}'
    manifests_src = f'{SRCDIR}/manifests'
    manifests_dist = f'{configuration_dist}/manifests'

    # Clean DISTDIR
    if isdir(configuration_dist):
        rmtree(configuration_dist)

    # Copy configuration
    copytree(configuration_src, configuration_dist)
    copytree(manifests_src, manifests_dist)

    # Replace templated version variable in clusters.tf
    replace_template(configuration_dist, 'clusters.tf',
                     {'version': version})

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


def compress(version, configuration):
    starter = f'{ARTIFACT_PREFIX}{configuration}'
    archive = f'{DISTDIR}/{starter}-{version}'
    make_archive(archive, 'zip', DISTDIR, starter)


if __name__ == "__main__":
    # Use tag as version, fallback to commit sha
    version = environ.get('GIT_SHA')
    # Non tagged images go to a different image repository
    image_name = 'kubestack/framework-dev'

    gitref = environ.get('GIT_REF')
    if gitref.startswith('refs/tags/'):
        version = gitref.replace('refs/tags/', '')
        # Tagged releases go to main image repository
        image_name = 'kubestack/framework'

    try:
        target = argv[1]
    except IndexError:
        print("positional arg: 'target' missing:")
        exit("usage dist.py [dist | compress]")

    configurations = [n for n in listdir(f'{SRCDIR}/configurations')
                      if not n.startswith('_')]

    if target not in ["dist", "compress"]:
        exit("usage dist.py [dist | compress]")

    for configuration in configurations:
        if target == "dist":
            dist(version, image_name, configuration)
            continue

        if target == "compress":
            compress(version, configuration)
            continue
