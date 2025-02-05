variable "flask_app_image" {
    description = "Docker image for Flask app"
    type        = string
    default     = "gideonisbuilding/flask-app:latest"
}

variable "replicas" {
    description = "Number of replicas for the Flask app"
    type        = number
    default = "gideonisbuilding/flask-app:2
}
