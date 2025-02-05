resource "kubernetes_service" "flask_app" {
    metadata {
        name      = "flask-app-service"
        namespace = "default"
    }

    spec {
        selector = {
        app = "flask-app"
        }

        port {
        port        = 80             #Port the service exposes to the outside world
        target_port = 3000           #Port the app is running on within the container
        }

        type = "LoadBalancer"           #LoadBalancer for cloud services and ClusterIP for internal access
        }
}
