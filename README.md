# Terraform K8s deployment


## About

The project allows the deployment of a K8s cluster in GCP. In addition, the option to deploy a sample application serving the http API has been added. The main objective was to write an automation using Terraform.

## Prerequisites
To run this project you need:
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- kubectl

## Infrastructure

### Description
The files in the 'infrastructure/' path are used to expose the infrastructure to the cloud. This includes VPC, subnet and GKE cluster. The number of nodes in the node pool were limited to be exposed within one zone in the region which was declared in the variables.
### Usage
Login to your Google account and select the project you want to work in.
```commandline
$ gcloud auth application-default login
```
Update `terraform.tfvars` with `project_id`, `region` and `zone`. <br/>
To find project with gcloud:
```commandline
$ gcloud config get-value project
```
Initialize Terraform workspace in `infrastructure/` directory
```commandline
$ terraform init
```
Start provisioning VPC, subnet and GKE
```commandline
$ terraform apply
```
To access `kubectl`
```
$ gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --zone $(terraform output -raw zone)
```

## App deployment

### Description
For this example, I used a simple containerized [application serving http API](https://hub.docker.com/r/thomaspoignant/hello-world-rest-json)
### Usage

Initialize Terraform workspace in `k8s/` directory
```commandline
$ terraform init
```
Start provisioning kubernetes deployment specified in `kubernetes.tf`
```commandline
$ terraform apply
```
The application should be visible at the link http://<`lb_ip`>:8080 <br/>
`lb_ip` can be seen as `terrraform apply` output
