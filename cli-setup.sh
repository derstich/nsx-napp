#!/bin/bash

#The Script will install Kubectl on the Management Server and download the .kube/config from Kubernetes Master

sudo apt-get update
sudo apt-get upgrade -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo echo 'deb http://apt.kubernetes.io/  kubernetes-xenial  main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl=$k8sversion
sudo apt-mark hold kubectl
mkdir -p $HOME/.kube
scp $k8smaster:.kube/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
