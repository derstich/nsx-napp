#!/bin/bash
export k8sversion=1.21.9-00
export k8sm=k8smaster.corp.local

sudo apt-get update
sudo apt-get upgrade -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo echo 'deb http://apt.kubernetes.io/  kubernetes-xenial  main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl=$k8sversion
sudo apt-mark hold kubectl
mkdir -p $HOME/.kube
scp $k8sm:.kube/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
