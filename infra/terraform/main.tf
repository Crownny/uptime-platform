terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-test"
}

resource "kubernetes_namespace_v1" "uptime" {
  metadata {
    name = "uptime"
  }
}

resource "kubernetes_deployment_v1" "api" {
  metadata {
    name      = "uptime-api"
    namespace = kubernetes_namespace_v1.uptime.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "uptime-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "uptime-api"
        }
      }

      spec {
        container {
          name              = "uptime-api"
          image             = "uptime-api:1.1"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 3000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "api" {
  metadata {
    name      = "uptime-api"
    namespace = kubernetes_namespace_v1.uptime.metadata[0].name
  }

  spec {
    selector = {
      app = "uptime-api"
    }

    port {
      port        = 80
      target_port = 3000
    }
  }
}