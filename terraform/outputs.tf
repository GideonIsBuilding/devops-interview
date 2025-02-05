output "flask_service_ip" {
    description = "The external IP of the Flask service"
    value       = kubernetes_service.flask_app.status[0].load_balancer[0].ingress[0].ip
}
