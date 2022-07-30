#!/bin/bash
#set -e

# note that the character '_' is an invalid value if you are replacing the defaults below
cluster1_context="cluster1"
cluster2_context="cluster2"
mgmt_context="mgmt"

# configure app of apps cluster1
kubectl apply -f ../platform-owners/cluster1/cluster1-apps.yaml --context ${cluster1_context}
kubectl apply -f ../platform-owners/cluster1/cluster1-cluster-config.yaml --context ${cluster1_context}
kubectl apply -f ../platform-owners/cluster1/cluster1-infra.yaml --context ${cluster1_context}
kubectl apply -f ../platform-owners/cluster1/cluster1-mesh-config.yaml --context ${cluster1_context}

# configure app of apps cluster2
kubectl apply -f ../platform-owners/cluster2/cluster2-apps.yaml --context ${cluster2_context}
kubectl apply -f ../platform-owners/cluster2/cluster2-cluster-config.yaml --context ${cluster2_context}
kubectl apply -f ../platform-owners/cluster2/cluster2-infra.yaml --context ${cluster2_context}
kubectl apply -f ../platform-owners/cluster2/cluster2-mesh-config.yaml --context ${cluster2_context}

# configure app of apps mgmt
kubectl apply -f ../platform-owners/mgmt/mgmt-apps.yaml --context ${mgmt_context}
kubectl apply -f ../platform-owners/mgmt/mgmt-cluster-config.yaml --context ${mgmt_context}
kubectl apply -f ../platform-owners/mgmt/mgmt-infra.yaml --context ${mgmt_context}
kubectl apply -f ../platform-owners/mgmt/mgmt-mesh-config.yaml --context ${mgmt_context}