#!/bin/bash
export iprange=192.168.110.81-192.168.110.90


curl -o antrea.yaml https://raw.githubusercontent.com/antrea-io/antrea/main/build/yamls/antrea.yml
kubectl apply -f antrea.yaml
kubectl create ns metallb-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml -n metallb-system
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
touch metallb-configmap.yaml
printf \
'apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - '$iprange'' \
| tee -a metallb-configmap.yaml
kubectl apply -f metallb-configmap.yaml
sudo snap install helm --classic
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=nfs-k8s.corp.local --set nfs.path=/nfs/k8s --set storageClass.onDelete=true