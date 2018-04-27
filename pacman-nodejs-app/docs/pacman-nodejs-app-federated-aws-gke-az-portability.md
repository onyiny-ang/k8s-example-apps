# Pac-Man Application On Federated Kubernetes Cluster With Multiple Public Cloud Provider Portability

This guide will walk you through creating multiple Kubernetes clusters spanning
multiple public cloud providers and use a federation control plane to deploy
the Pac-Man Node.js application onto each cluster, then move it away from AWS.
The Kubernetes clusters and Pac-Man application will be deployed using the
following public cloud providers: Google Cloud Platform, Amazon Web Services,
and Azure.

## High-Level Architecture

Below is a diagram demonstrating the architecture of the game across the federated kubernetes cluster after all the steps are completed.

![Pac-Man Game
Architecture](images/Kubernetes-Federation-Game-AWS-GKE-AZ-Portability.png)

## Prerequisites

#### Follow instructions for deploying Pac-Man on multiple cloud providers

You'll first need to deploy the federated control plane, then the Pac-Man
application so that you have a working Pac-Man game working across all three
cloud providers: AWS, GKE, and Azure. In order to do this, follow the
instructions at the following link up until you can play the game. Once
complete, return back here for the tutorial on migrating Pac-Man away from AWS.

- [Pac-Man application deployed on multiple public cloud providers in a federation: GKE, AWS, and Azure](docs/pacman-nodejs-app-federated-multicloud.md)

## Migrate Pac-Man away from the AWS Kubernetes Cluster

Once you've played Pac-Man to verify your application has been properly
deployed, we'll migrate the application away from AWS to just the GKE and Azure
Kubernetes cluster only.

### Migrate Pac-Man Resources

Migrating the Pac-Man resources away from AWS is as simple as migrating the
`pacman` namespace. In order to do that, we need to modify the `pacman`
`federatednamespaceplacement` resource to specify that we no longer want AWS as
the cluster hosting the `pacman` namespace and all its contents.  The following
command enables you to do that:

```bash
kubectl patch federatednamespaceplacement pacman -p \
    '{"spec":{"clusternames": ["gke-us-west1", "az-us-central1"]}}'
```

Wait until the pacman deployment no longer shows pods running in the AWS
cluster:

```bash
for i in ${CLUSTERS}; do
    kubectl --context=${i} get deploy pacman -o wide
done
```

### Update DNS records

Until the federation-v2 DNS load balancing feature is implemented, we need to
udpate the DNS entry to no longer point to the AWS cluster's `pacman` federated
service load balancer IP address. To do that, run the following script:

```

```

## Play Pac-Man

Go ahead and play a few rounds of Pac-Man and invite your friends and
colleagues by giving them your FQDN to your Pac-Man application e.g.
[http://pacman.example.com/](http://pacman.example.com/) (replace
`example.com` with your DNS name).

The DNS will load balance (randomly) and resolve to any one of the zones in
your federated kubernetes cluster. This is represented by the `Cloud:` and
`Zone:` fields at the top, as well as the `Host:` Pod that it's running on.
When you save your score, it will automatically save these fields corresponding
to the instance you were playing on and display it in the High Score list.

See who can get the highest score!

## Cleanup

#### Delete Pac-Man Resources

##### Delete Pac-Man Deployment and Service

Delete Pac-Man federated deployment and service.

```bash
kubectl delete federateddeployment/pacman federatedservice/pacman
kubectl delete federateddeploymentplacement/pacman federatedserviceplacement/pacman
```

#### Delete MongoDB Resources

##### Delete MongoDB Deployment and Service

Delete MongoDB federated deployment and service.

```bash
kubectl delete federateddeployment/mongo federatedservice/mongo
kubectl delete federateddeploymentplacement/mongo federatedserviceplacement/mongo
```

##### Delete MongoDB Persistent Volume Claims

```bash
for i in ${CLUSTERS}; do \
    kubectl --context=${i} delete pvc/mongo-storage; \
done
```

#### Delete DNS entries in Google Cloud DNS

Delete the `mongo` and `pacman` DNS entries that were created in your
[Google DNS Managed Zone](https://console.cloud.google.com/networking/dns/zones).

#### Cleanup rest of federation cluster

Follow these guides to cleanup the clusters:

1. [Steps to clean-up your federation cluster created using kubefnord](kubernetes-cluster-federation.md#cleanup).
2. Remove each cluster: [Azure](kubernetes-cluster-azure.md#cleanup),
   [AWS](kubernetes-cluster-aws.md#cleanup), and [GKE](kubernetes-cluster-gke-federation.md#delete-kubernetes-clusters)

#### Remove kubectl config contexts

Remove kubectl contexts:

```bash
for i in ${CLUSTERS}; do \
    kubectl config delete-context ${i}
done
```
