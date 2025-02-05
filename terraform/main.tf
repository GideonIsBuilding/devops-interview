resource "kubernetes_deployment" "flask_app" {
    metadata {
        name      = "flask-app"
        namespace = "default"
    }

    spec {
        replicas = var.replicas
        selector {
        match_labels = {
            app = "flask-app"
        }
        }

        template {
        metadata {
            labels = {
            app = "flask-app"
            }
        }

        spec {
            container {
            name  = "flask-app"
            image = var.flask_app_image
            port {
                container_port = 3000
            }
            env {
                name  = "FLASK_ENV"
                value = "production"
            }
            }
        }
        }
    }
}
