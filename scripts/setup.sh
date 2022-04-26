#!/bin/bash

set -e

# Install necessary dependencies
sudo apt-get -y -qq install ca-certificates curl gnupg lsb-release

# Install Docker
curl "https://mirror.yandex.ru/mirrors/docker/dists/focal/pool/stable/amd64/docker-ce_20.10.9~3-0~ubuntu-focal_amd64.deb" -o docker-ce.deb
curl "https://mirror.yandex.ru/mirrors/docker/dists/focal/pool/stable/amd64/containerd.io_1.5.11-1_amd64.deb" -o containerd.io.deb
curl "https://mirror.yandex.ru/mirrors/docker/dists/focal/pool/stable/amd64/docker-ce-cli_20.10.9~3-0~ubuntu-focal_amd64.deb" -o docker-ce-cli.deb
curl "https://mirror.yandex.ru/mirrors/docker/dists/focal/pool/stable/amd64/docker-ce-rootless-extras_20.10.14~3-0~ubuntu-focal_amd64.deb" -o docker-ce-rootless-extras.deb
sudo apt-get install -y -qq ./*.deb
sudo usermod -aG docker $USER
