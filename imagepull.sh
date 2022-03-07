#!/bin/bash

#Project Antrea
sudo docker pull docker pull projects.registry.vmware.com/antrea/antrea-ubuntu:latest

#Metallb
sudo docker pull quay.io/metallb/controller:main
sudo docker pull quay.io/metallb/speaker:main

#CertManager Files
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-controller:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-cainjector:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-webhook:19067763

#Project Contour
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/contour:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/envoy:19067763

#NSXI Platform
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/spark-operator:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluentd:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/minio:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/mc:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/druid:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/zookeeper:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/redis:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/cluster_api:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/postgresql-repmgr:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/routing_controller:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluent-bit:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_manager:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_query_server:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics-app:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_db_helper:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_nsx_config:19067763

#

sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/hombre:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-deployment-precheck:123-c33a1aa7.bionic
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-ssl-tunnel:123-31bb14c6.bionic
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-registration-scripts:19067767
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-register-nsx-to-lastline-cloud:123-c33a1aa7.bionic
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/recommendation-spark-job:19067763
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/reputation-service:19067759
sudo docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx_config:19067763
