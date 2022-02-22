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
