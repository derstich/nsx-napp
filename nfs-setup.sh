#!/bin/bash
# Install NFS Application
sudo apt install nfs-kernel-server nfs-common -y

#Format the second Disk without userinteraction. 
echo -e 'n\np\n1\n\n\nw' | sudo fdisk /dev/$sdx
sudo mkfs.ext4 /dev/$sdx1

#Create a Folder and mount the Folder to the newly formated Disk 
sudo mkdir /$nfsfolder
sudo mount /dev/$sdx1 /$nfsfolder
echo '/dev/$sdx1       /$nfsfolder    ext4    defaults     0   0' | sudo tee -a /etc/fstab

#Create a Subfolder for the NFS Share
sudo mkdir /$nfsfolder/$nfssubfolder -p

#Make an entry for the Subfolder in /etc/exports
echo '/$nfsfolder/$nfssubfolder               *(rw,sync,no_root_squash,no_subtree_check)' | sudo tee -a /etc/exports
sudo chown nobody:nogroup /$nfsfolder/$nfssubfolder/

#Restart the NFS Server
sudo systemctl restart nfs-kernel-server
