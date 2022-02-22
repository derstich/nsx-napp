#!/bin/bash

#set Variables

#Hostnames
export k8sm=k8smaster.corp.local
export k8sn=k8snode.corp.local
export nfs=nfs-k8s.corp.local
export k8shost="$k8sm $k8sn"
export allhosts="$k8sm $k8sn $nfs"

#NFS Information
#Disk to use
export sdx=sdb
#Folder for NFS
export nfsfolder=nfs 
export nfssubfolder=k8s

#K8S Information
export k8sversion=1.21.9-00

#LB IP Pool
export iprange=192.168.110.81-192.168.110.90
