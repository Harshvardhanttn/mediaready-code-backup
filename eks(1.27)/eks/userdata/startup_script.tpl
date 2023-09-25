#!/bin/bash -xe
sudo /etc/eks/bootstrap.sh --apiserver-endpoint '${CLUSTER-ENDPOINT}' --b64-cluster-ca '${CERTIFICATE_AUTHORITY_DATA}' '${CLUSTER_NAME}'
mkdir /tmp/logs
