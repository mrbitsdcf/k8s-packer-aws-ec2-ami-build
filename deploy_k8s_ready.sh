#!/bin/bash

set -o errexit  # Exit on error
set -o nounset  # Undefined variables
set -o pipefail # Pipes or commands

# Enable all repositories
cat <<__EOF__>/etc/apt/sources.list
deb http://archive.canonical.com/ubuntu bionic partner
deb http://archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse
__EOF__

# Update OS
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get \
    -o Dpkg::Options::=--force-confold \
    -o Dpkg::Options::=--force-confdef \
    -y --allow-downgrades --allow-remove-essential \
    --allow-change-held-packages dist-upgrade

# Install Docker
curl -s https://get.docker.com/ | bash

# Configure Docker cgroups
cat <<__EOF__>/etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
__EOF__

# Reload Docker
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker

# Configure OS to support bridge virtual networks
cat <<__EOF__> /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
__EOF__
sysctl --system

# Install Kubernetes binaries
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<__EOF__> /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-focal main
__EOF__
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get \
    -o Dpkg::Options::=--force-confold \
    -o Dpkg::Options::=--force-confdef \
    -y --allow-downgrades --allow-remove-essential \
    --allow-change-held-packages install kubelet kubeadm kubectl docker-compose
apt-mark hold kubelet kubeadm kubectl
