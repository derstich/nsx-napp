#!/bin/bash

#Swap must be disabled for Kubernetes
sudo swapoff -a
sudo sed -i -e 's\/swap.img\#/swap.img\g' /etc/fstab

#Bring the System up to date
sudo apt-get update
sudo apt-get upgrade -y

#Install Docker and change the croupdriver to systemd
sudo apt-get install -y docker.io
sudo systemctl enable docker.service
sudo systemctl start docker
sudo touch /etc/docker/daemon.json
sudo printf \
'{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": { "max-size": "100m" },
   "storage-driver": "overlay2"
}'\
| sudo tee -a /etc/docker/daemon.json
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker

#Install Kubernetes Packages
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo echo 'deb http://apt.kubernetes.io/  kubernetes-xenial  main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm=$k8sversion kubelet=$k8sversion kubectl=$k8sversion
sudo apt-mark hold kubelet kubeadm kubectl

#For the NFS Provisioner we need to install the NfS Client on all Kubernetes Mashines
sudo apt install nfs-client -y

#To use the full Disksize for Kubernete we need to increase the logical Volume
sudo lvextend -l +100%FREE $pathdevmap
sudo resize2fs $pathdevmap
