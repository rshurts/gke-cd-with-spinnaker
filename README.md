# Google Kubernetes Engine Continuous Delivery with Spinnaker

This is a guide to deploying spinnaker to GKE to set up a continuous delivery pipeline.

> Warning: This is a work in progress. Please review all code and configuration for applicability to your solution and submit pull requests back to improve the quality of this pipeline.

To Do:
- [ ] Setup Terraform remote state.
- [ ] Bake in Jenkins configuration as part of the Spinnaker Helm deploy.
- [ ] Create a wrapper script with configuration yaml to automate the setup steps.
- [ ] Create an example application with build and deploy configurations to demonstrate and test the pipeline.
- [ ] Add and improve documentation around using container registries.
- [ ] Add and improve documentation around watching source code repositories for changes.

## Pipeline architecture

<p align="center">
  <img src="GKE-Spinnaker.png?raw=true" alt="GKE Spinnaker Pipeline"/>
</p>

## Prerequisites

Command line tools:

- `gcloud`
- `terraform`
- `kubectl`
- `helm`

A GCP project with the following APIs enabled:

- Kubernetes Engine
- Container Builder
- Resource Manager


## Provision infrastructure

Run the following commands:
1. `export PROJECT=<Your GCP project id, like spinnaker-196519>`
1. `cd /path/to/repo/terraform`
1. `terraform apply -var project="$PROJECT" zone="<your GCP zone, like us-central1-a>"`

> Warning: Terraform remote state currently isn't set up, so all state is stored locally. This works for development, but should be changed for production purposes.

## Setup and save configurations

1. `cd /path/to/repo/terraform`
1. `export CA_DATA=$(terraform output kubernetes-certificate-authority-data)`
1. `export K8S_SERVER=$(terraform output kubernetes-server)`
1. `export K8S_NAME=$(terraform output kubernetes-name)`
1. `export BUCKET=$(terraform output spinnaker-config-bucket)`
1. `terraform output kubernetes-client-certificate | base64 -D > ../kubernetes/client.pem`
1. `terraform output kubernetes-client-key | base64 -D > ../kubernetes/client-key.pem`
1. `terraform output spinnaker-private-key | base64 -D > ../helm/spinnaker-sa.json`

## Setup kubernetes config and create services accounts and bind roles

1. `cd /path/to/repo/kubernetes`
1. `sed "s#CA_DATA#$CA_DATA#g; s#K8S_SERVER#$K8S_SERVER#g; s#K8S_NAME#$K8S_NAME#g" config-template.yaml > config.yaml`
1. `export KUBECONFIG=:$PWD/config.yaml`
1. `kubectl create -f tiller.yaml`
1. `kubectl create -f spinnaker.yaml`

## Use helm to install jenkins and spinnaker on kubernetes

> Tip: Spinnaker adhears to immutable infrastructure principles. To change the spinnaker configuration change the yaml file and use the `helm upgrade` command.

1. `cd /path/to/repo/helm`
1. `helm init --service-account=tiller`
1. `sed "s#SPINNAKER_BUCKET#$BUCKET#g; s#PROJECT_ID#$PROJECT#g" spinnaker-config-template.yaml > spinnaker-config.yaml`
1. Copy the contents of `spinnaker-sa.json` into the `SPINNAKER_SA_JSON` entries in `spinnaker-config.yaml`.
1. `helm install -n cd stable/spinnaker -f spinnaker-config.yaml --timeout 600 --version 0.4.0`

## Open jenkins and spinnaker locally

> Tip: Use two separate terminals run these commands. Make sure to `export KUBECONFIG=:/path/to/repo/kubernetes/config.yaml` so `kubectl` works.

1. `export JENKINS_POD=$(kubectl get pods --namespace default -l "app=cd-jenkins" -o jsonpath="{.items[0].metadata.name}")`
1. `kubectl port-forward --namespace default $JENKINS_POD 8080`
1. Open http://localhost:8080
1. `export DECK_POD=$(kubectl get pods --namespace default -l "component=deck,app=cd-spinnaker" -o jsonpath="{.items[0].metadata.name}")`
1. `kubectl port-forward --namespace default $DECK_POD 9000`
1. Open http://localhost:9000
