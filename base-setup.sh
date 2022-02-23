#!/bin/bash

#set Variables
export installfiles=~/nappinstall
#Hostnames
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
ssh $nfs bash $installfiles/nfs-setup.sh

#ALL K8S
curl -o $installfiles/k8s-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8s-setup.sh
sed -i -e 's\$k8sversion\'$k8sversion'\g' $installfiles/k8s-setup.sh
sed -i -e 's\$pathdevmap\'$pathdevmap'\g' $installfiles/k8s-setup.sh
for host in $k8shost; do
scp $installfiles/k8s-setup.sh $host:$installfiles/
ssh $host bash $installfiles/k8s-setup.sh
done

#K8S-Master
curl -o $installfiles/k8smaster-setup.sh https://raw.githubusercontent.com/derstich/nsx-napp/main/k8smaster-setup.sh
sed -i -e 's\$kubeadmfolder\'$kubeadmfolder'\g' $installfiles/k8smaster-setup.sh
export k8sversionshort=${k8sversion::-3}
sed -i -e 's\$k8sversionshort\'$k8sversionshort'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$k8smaster\'$k8sm'\g' $installfiles/k8smaster-setup.sh
sed -i -e 's\$podnet\'$podnet'\g' $installfiles/k8smaster-setup.sh
scp $installfiles/k8smaster-setup.sh $k8sm:$installfiles/
ssh $k8sm bash $installfiles/k8smaster-setup.sh

#Enable K8S on Nodes
ssh $k8sm tail -n 2 $kubeadmfolder/kubeadm-init.out >> $installfiles/kubeadm-node.sh
for k8snodes in $k8sn; do
cat $installfiles/kubeadm-node.sh | ssh $k8snodes sudo -i
done

#Enable Management Host
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

#Optional upload kube/config to nsx manager
curl -k -u ''$nsxuser':'$nsxpasswd'' -H 'Accept:application/json' -d '{"docker_registry":"'$dockerregistry'","helm_repo":"'$helmrepo'"}' https://$nsxmanager/policy/api/v1/infra/sites/default/napp/deployment/registry
curl -k -u ''$nsxuser':'$nsxpasswd'' -H 'Accept:application/json' -F 'file=@./.kube/config' https://$nsxmanager/policy/api/v1/infra/sites/default/napp/deployment/kubeconfig
