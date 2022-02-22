#!/bin/bash

#Set variables
sdx=sdb
nfsfolder=nfs
nfs-subfolder=k8s

#run commands
sudo apt install nfs-kernel-server nfs-common -y
echo -e 'n\np\n1\n\n\nw'| sudo fdisk /dev/$sdx
sudo mkfs.ext4 /dev/$sdx'1'
sudo mkdir /$nfsfolder
sudo mount /dev/$sdx'1' /$nfsfolder
echo '/dev/'$sdx'1       /'$nfsfolder'    ext4    defaults     0   0' | sudo tee -a /etc/fstab
sudo mkdir /$nfsfolder/$nfssubfolder -p
echo '/'$nfsfolder'/'$nfssubfolder'               *(rw,sync,no_root_squash,no_subtree_check)' | sudo tee -a /etc/exports
sudo chown nobody:nogroup /$nfsfolder/$nfssubfolder/
sudo systemctl restart nfs-kernel-server
