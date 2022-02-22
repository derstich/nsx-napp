#!/bin/bash

#set Variables
export installfiles=~/nappinstall
#Hostnames
export k8sm=k8smaster.corp.local
export k8sn=k8snode.corp.local
export nfs=nfs-k8s.corp.local
export k8shost="$k8sm $k8sn"
export allhost="$k8sm $k8sn $nfs"

#NFS Information
#Disk to use
export sdx=sdb
#Folder for NFS
export nfsfolder=nfs
export nfssubfolder=k8s

#K8S Information
export k8sversion=1.21.9-00
export pathdevmap=/dev/mapper/ubuntu--vg-ubuntu--lv
export kubeadmfolder=~/kubeadm
export podnet=172.25.0.0/16

#LB IP Pool
export iprange=192.168.110.81-192.168.110.90

mkdir $installfiles
for allhosts in $allhost; do
ssh $allhosts mkdir $installfiles
done

#NFS
curl -o $installfiles/nfs-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/nfs-setup.sh
sed -i -e 's\$sdx\'$sdx'\g' $installfiles/nfs-setup.sh
sed -i -e 's\$nfsfolder\'$nfsfolder'\g' $installfiles/nfs-setup.sh
sed -i -e 's\$nfssubfolder\'$nfssubfolder'\g' $installfiles/nfs-setup.sh
scp $installfiles/nfs-setup.sh $nfs:$installfiles/

#ALL K8S
curl -o $installfiles/k8s-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8s-setup.sh
sed -i -e 's\$k8sversion\'$k8sversion'\g' $installfiles/k8s-setup.sh
sed -i -e 's\$pathdevmap\'$pathdevmap'\g' $installfiles/k8s-setup.sh
for host in $k8shost; do
scp $installfiles/k8s-setup.sh $host:$installfiles/
done

#K8S-Master
curl -o $installfiles/k8smaster-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8smaster-setup.sh
sed -i -e 's\$kubeadmfolder\'$kubeadmfolder'\g' $installfiles/k8smaster-setup.sh
export k8sversionshort=${k8sversion::-3}
sed -i -e 's\$k8sversionshort\'$k8sversionshort'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$k8smaster\'$k8sm'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$podnet\'$podnet'\g' $installfiles/k8smaster-setup.sh
scp $installfiles/k8smaster-setup.sh $k8sm:$installfiles/
