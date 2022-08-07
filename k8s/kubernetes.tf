terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../infrastructure/terraform.tfstate"
  }
}

provider "google" {
  project = data.terraform_remote_state.gke.outputs.project_id
  zone  = data.terraform_remote_state.gke.outputs.zone
}

data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.gke.outputs.zone
}

provider "kubernetes" {
  host = data.terraform_remote_state.gke.outputs.kubernetes_cluster_host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}


resource "kubernetes_deployment" "hello" {
  metadata {
    name = "scalable-hello-example"
    labels = {
      App = "ScalablehelloExample"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ScalablehelloExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalablehelloExample"
        }
      }
      spec {
        container {
          image = "thomaspoignant/hello-world-rest-json"
          name  = "example"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello" {
  metadata {
    name = "hello-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.hello.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.hello.status.0.load_balancer.0.ingress.0.ip
}
