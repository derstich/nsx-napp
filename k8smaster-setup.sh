#!/bin/bash

#The Script create a Kubeadm Config, install Kubernetes and store the results in the File kubeadm-init.out

mkdir $kubeadmfolder
touch $kubeadmfolder/kubeadm-config.yaml
printf \
'apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: $k8sversionshort
controlPlaneEndpoint: "$k8smaster:6443"
networking:
  podSubnet: $podnet' \
| tee -a $kubeadmfolder/kubeadm-config.yaml

sudo kubeadm init --config=$kubeadmfolder/kubeadm-config.yaml --upload-certs | tee $kubeadmfolder/kubeadm-init.out

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
