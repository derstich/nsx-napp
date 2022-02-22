#!/bin/bash
export k8sfolder=~/k8sinstall
export k8sversion=1.21.9
export cpe=k8smaster
export podnet=172.25.0.0/16

mkdir $k8sfolder
touch $k8sfolder/kubeadm-config.yaml
printf \
'apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: '$k8sversion'
controlPlaneEndpoint: "'$cpe':6443"
networking:
  podSubnet: '$podnet'' \
| sudo tee -a $k8sfolder/kubeadm-config.yaml

sudo kubeadm init --config=$k8sfolder/kubeadm-config.yaml --upload-certs | sudo tee $k8sfolder/kubeadm-init.out

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
