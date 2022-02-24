#!/bin/bash

#set Variables
#Username (loginname for the servers K8S+NFS)
export user=acme

#Place for the Installation Scripts (can be deleted after the installation)
export installfiles=/home/$user/nappinstall

#Hostnames (Server FQDN)
export k8sm=k8smaster.corp.local
export k8sn1=k8snode.corp.local
export k8sn2=
export k8sn3=
export nfs=nfs-k8s.corp.local
export k8sn="$k8sn1 $k8sn2 $k8sn3"
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
export k8sconfigfiles=~/k8sconfigfiles

#LB IP Pool
export ippool=192.168.110.81-192.168.110.90

#NSX Manager Information
export nsxmanager=192.168.110.7
export nsxuser=admin
export nsxpasswd='VMware1!VMware1!'
export dockerregistry='projects.registry.vmware.com/nsx_application_platform/clustering'
export helmrepo='https://projects.registry.vmware.com/chartrepo/nsx_application_platform'


#------------------------------------------

#Create Server Groups
export k8sn="$k8sn1 $k8sn2 $k8sn3"
export k8shost="$k8sm $k8sn"
export allhost="$k8sm $k8sn $nfs"

#Create a Directory for the Installation Files on all Servers
mkdir $installfiles
for allhosts in $allhost; do
ssh $user@$allhosts mkdir $installfiles
done

#NFS Configuration
#Download the nfs-setup script
curl -o $installfiles/nfs-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/nfs-setup.sh

#modify the settings
sed -i -e 's\$sdx\'$sdx'\g' $installfiles/nfs-setup.sh
sed -i -e 's\$nfsfolder\'$nfsfolder'\g' $installfiles/nfs-setup.sh
sed -i -e 's\$nfssubfolder\'$nfssubfolder'\g' $installfiles/nfs-setup.sh

#uplod script to NFS Server
scp $installfiles/nfs-setup.sh $user@$nfs:$installfiles/
#execute the Script on NFS Server
ssh $user@$nfs bash $installfiles/nfs-setup.sh

#Setup all Kubernetes Server
#Download the k8s-setup script
curl -o $installfiles/k8s-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8s-setup.sh

#modify the settings
sed -i -e 's\$k8sversion\'$k8sversion'\g' $installfiles/k8s-setup.sh
sed -i -e 's\$pathdevmap\'$pathdevmap'\g' $installfiles/k8s-setup.sh

# Upload the script to all Kubernetes Server and execute the Script
for host in $k8shost; do
scp $installfiles/k8s-setup.sh $user@$host:$installfiles/
ssh $user@$host bash $installfiles/k8s-setup.sh
done

#Additional setup on Kubernetes Master
#Download k8smaster-setup script
curl -o $installfiles/k8smaster-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8smaster-setup.sh

#modify the settings
sed -i -e 's\$kubeadmfolder\'$kubeadmfolder'\g' $installfiles/k8smaster-setup.sh
export k8sversionshort=${k8sversion::-3}
sed -i -e 's\$k8sversionshort\'$k8sversionshort'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$k8smaster\'$k8sm'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$podnet\'$podnet'\g' $installfiles/k8smaster-setup.sh

#upload script to K8Smaster
scp $installfiles/k8smaster-setup.sh $user@$k8sm:$installfiles/

#exectue the Scrip on K8Smaster
ssh $user@$k8sm bash $installfiles/k8smaster-setup.sh

#Download the Kubeadm Init from K8S and execute on Worker Nodes
ssh $user@$k8sm tail -n 2 $kubeadmfolder/kubeadm-init.out >> $installfiles/kubeadm-node.sh
for k8snodes in $k8sn; do
cat $installfiles/kubeadm-node.sh | ssh $user@$k8snodes sudo -i
done

# Install Kubectl on Management Host
curl -o $installfiles/cli-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/cli-setup.sh
sed -i -e 's\$k8sversion\'$k8sversion'\g' $installfiles/cli-setup.sh
sed -i -e 's\$k8smaster\'$k8sm'\g' $installfiles/cli-setup.sh
bash $installfiles/cli-setup.sh

#Setup Loadbalancer MetalB
curl -o $installfiles/k8sprep.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8sprep.sh
mkdir $k8sconfigfiles
sed -i -e 's\$k8sconfigfiles\'$k8sconfigfiles'\g' $installfiles/k8sprep.sh
sed -i -e 's\$ippool\'$ippool'\g' $installfiles/k8sprep.sh
bash $installfiles/k8sprep.sh

#Optional upload kube/config to nsx manager (needed later for NAPP Installation)
curl -k -u ''$nsxuser':'$nsxpasswd'' -X PUT -H "Content-Type: application/json" -d '{"docker_registry":"'$dockerregistry'","helm_repo":"'$helmrepo'"}' https://$nsxmanager/policy/api/v1/infra/sites/default/napp/deployment/registry
curl -k -u ''$nsxuser':'$nsxpasswd'' -H 'Accept:application/json' -F 'file=@./.kube/config' https://$nsxmanager/policy/api/v1/infra/sites/default/napp/deployment/kubeconfig
