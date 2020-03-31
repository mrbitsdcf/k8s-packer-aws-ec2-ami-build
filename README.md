AWS EC2 AMI ready for Kubernetes Builder
========================================

Purpose
-------

Create an EC2 AMI ready to run Kubernetes (in case you don't want to run EKS) with:

- Ubuntu 18.04
- docker-ce
- kubeadm
- kubelet
- kubectl
- OS updated and configured to run systemd cgroups


How to use
----------

First, install Hashicorp Packer using one method as described here: https://packer.io/intro/getting-started/install.html

Export your AWS credentials:

```
export AWS_ACCESS_KEY_ID=AKIAWWWWWWWWWWWWWWWW
export AWS_SECRET_ACCESS_KEY=gKggKggKggKggKggKggKggKggKg
```

Run packer

```
packer build k8s_ready_vm.json
```

Wait to finish and launch an EC2 instance to test.
