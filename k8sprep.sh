#!/bin/bash
export iprange=192.168.110.81-192.168.110.90


#Install CNI
curl -o $k8sconfigfiles/antrea.yaml https://raw.githubusercontent.com/antrea-io/antrea/main/build/yamls/antrea.yml
kubectl apply -f $k8sconfigfiles/antrea.yaml
#Install LoadBalancer MetalB
kubectl create ns metallb-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml -n metallb-system
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
touch $k8sconfigfiles/metallb-configmap.yaml
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
      - $ippool' \
| tee -a $k8sconfigfiles/metallb-configmap.yaml
kubectl apply -f $k8sconfigfiles/metallb-configmap.yaml
#Install NFS Provisioner
sudo snap install helm --classic
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=$nfs --set nfs.path=/$nfsfolder/$nfssubfolder --set storageClass.onDelete=true
