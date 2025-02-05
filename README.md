# Flask Hello World Application

This is a simple Python web application using the **Flask** framework. The app will display "Hello World!" when you visit it in your browser.

## Prerequisites

Before you start, make sure you have the following installed on your computer:

- **Python** (version 3.6 or higher. We'd advise 3.10)
- **pip** (Python package installer)

You can check if Python is installed by running:
```bash
python --version
```
If Python is not installed, [download and install it here](https://www.python.org/downloads/).

## Setting Up the Project

### 1. **Clone or Download the Project**

If you don't have this project already, you can create a folder for it or clone/download it using Git:
```bash
git clone https://github.com/your-username/flask-hello-world.git
cd flask-hello-world
```
Alternatively, you can manually create the following files and copy the code from below.

### 2. **Create a Virtual Environment (Optional but Recommended)**

Using a virtual environment helps isolate your project's dependencies. To create a virtual environment, run:

```bash
python -m venv venv
```

Then activate the virtual environment:
- **On Windows**:
  ```bash
  venv\Scripts\activate
  ```
- **On macOS/Linux**:
  ```bash
  source venv/bin/activate
  ```

### 3. **Install Flask**

Once the virtual environment is activated, install Flask using **pip**:

```bash
pip install flask
```

This will install the Flask framework in your virtual environment.

### 4. **Create the Application**

Create a Python file named `app.py` (or use the provided file if you cloned the repository) and add the following code to it:

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
```

### 5. **Run the Application**

With everything set up, you can now run the application using the following command:

```bash
python app.py
```

This will start the Flask development server, and you should see output like:

```
 * Running on http://0.0.0.0:3000/ (Press CTRL+C to quit)
```

### 6. **Access the Application**

- Open your web browser and go to:  
  [http://localhost:3000](http://localhost:3000)  
  or  
  [http://127.0.0.1:3000](http://127.0.0.1:3000).

- You should see the message: `Hello World!`.

---

## Troubleshooting

### **1. Flask is not installed**

If you see an error like `ModuleNotFoundError: No module named 'flask'`, it means Flask isn't installed.

To fix this, make sure you are in your virtual environment and run:
```bash
pip install flask
```

### **2. Port 3000 is already in use**

If you see an error saying that port 3000 is already in use, you can change the port number in the `app.run()` line:

```python
app.run(host='0.0.0.0', port=5000)
```

This will make the app run on port 5000 instead.

### **3. Can't access from other devices**

If you’re running this app in a local development environment and can’t access it from another device on the same network, make sure that your firewall allows connections on port 3000, and that you're using the correct IP address. Use the IP of your machine (e.g., `http://192.168.0.10:3000`).

### **4. Permission issues on macOS/Linux**

If you’re getting permission errors (especially on macOS/Linux), you might need to run the app as an administrator using `sudo`. However, using a virtual environment should usually prevent this.

---

## Next Steps

Deploying your Flask app in Kubernetes is a great way to ensure scalability and manageability. Here’s a step-by-step guide on how to deploy the Flask application using Kubernetes.

### Prerequisites
- **Docker** installed: We need to containerize the application.
- **Kubernetes** cluster set up: You can use Minikube, Google Kubernetes Engine (GKE), or any other Kubernetes setup.
- **kubectl** installed: This is the command-line tool to interact with your Kubernetes cluster.
- **DockerHub** or any container registry account to push images (optional, but needed if you want to deploy remotely).

---

### 1. **Dockerize the Flask Application**

Before deploying your Flask app to Kubernetes, you need to containerize it using Docker.

#### a. **Create a Dockerfile**

In the same directory as your `app.py`, create a `Dockerfile`. This file defines how the application is built into a Docker container.

Here's an example `Dockerfile`:

```dockerfile
# Python Alpine image as a base
FROM python:3.10-alpine

# Working reference directory inside the container
WORKDIR /app

# Copy requirements file into container
COPY requirements.txt .

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of application code into container
COPY . .

# Expose port app runs on
EXPOSE 3000

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:3000", "app:app"]
```

#### b. **Create a `requirements.txt`**

Create a `requirements.txt` file to list your app's dependencies. This is necessary for Docker to install them. To create one, enter:

```
pip freeze -l > requirements.txt
```

#### c. **Build the Docker Image**

Now, build the Docker image using the following command:

```bash
docker build -t flask-hello-world .
```

This command will build the image using the `Dockerfile` in the current directory (`.`), and tag it as `flask-hello-world`.

#### d. **Run the Docker Container Locally (Optional)**

Before pushing the image to a registry, you can test it locally by running the following command:

```bash
docker run -p 3000:3000 flask-hello-world
```

This will run the container and map port 3000 of the container to port 3000 on your local machine. You can check the app at `http://localhost:3000`.

---

### 2. Configure GitHub Actions CI/CD Pipeline

To automate the build, push, and deployment process, we’ve set up a **GitHub Actions CI/CD pipeline**.

#### a. **Create a GitHub Actions Workflow File**

In the root directory of your project, create the `.github/workflows/ci.yml` file:

```yaml
name: CI Python Application

on:
  push:
    branches:
      - main

permissions:
  contents: write

jobs:
  app-ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          persist-credentials: true

      - name: Docker Login
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and Push Python App
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/flask-app:${{ github.run_number }} .
          docker push ${{ secrets.DOCKER_USERNAME }}/flask-app:${{ github.run_number }}

      - name: Update Terraform Script
        run: |
          cd terraform
          sed -i "s|\(default\s*=\s*\"\)[^\"]\+\(\"\)|\1${{ secrets.DOCKER_USERNAME }}/flask-app:${{ github.run_number }}\2|" variables.tf
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add variables.tf
          git commit -m "Update variables.tf"
          git push
```

#### b. **Explanation of the Workflow**

- **`Docker Login`**: Logs into DockerHub using credentials stored in GitHub secrets (`DOCKER_USERNAME` and `DOCKER_PASSWORD`).
- **`Build and Push Python App`**: Builds the Docker image for the Flask app and tags it with the current `run_number`. Then, it pushes the image to DockerHub.
- **`Update Terraform Script`**: Updates the Docker image tag in the Terraform `variables.tf` file. This ensures that Terraform uses the correct Docker image for future deployments. After the update, it commits and pushes the changes to the repository.

---

### 3. Setup Secrets in GitHub

For the GitHub Actions workflow to work, you need to store sensitive data (like DockerHub credentials) in **GitHub Secrets**.

To set secrets:
1. Go to your GitHub repository.
2. Click on **Settings** > **Secrets** > **New repository secret**.
3. Add the following secrets:
   - `DOCKER_USERNAME`: Your DockerHub username.
   - `DOCKER_PASSWORD`: Your DockerHub password (or token).

---

### How to Trigger the CI/CD Workflow

The workflow in your `.github/workflows/ci.yml` is set to automatically run whenever there’s a **push** to the `main` branch:

```yaml
on:
  push:
    branches:
      - main
```

This means that the workflow will be triggered automatically in the following scenarios:

1. **Push to the `main` branch**:
   - Whenever you push new changes to the `main` branch (e.g., through a `git push`), the GitHub Actions workflow will automatically start.

2. **Manual trigger through a GitHub Action event** (optional):
   - You can also manually trigger the workflow if needed via the GitHub UI (from the "Actions" tab).

### Steps to Trigger the Workflow

#### Option 1: Push Changes to the `main` Branch

1. After making changes to your code, commit them as you normally would:

```bash
git add .
git commit -m "Your commit message"
```

2. Push your changes to the `main` branch:

```bash
git push origin main
```

This will trigger the GitHub Actions workflow to run automatically, performing the following steps:

- Build the Docker image.
- Push the image to DockerHub.
- Update the Terraform variables to point to the new image.
- Deploy the app to Kubernetes using Terraform.

#### Option 2: Manually Trigger the Workflow (if needed)

If you want to manually trigger the workflow, you can do so from the **GitHub UI**:

1. Go to the **"Actions"** tab of your GitHub repository.
2. Select the **"CI Python Application"** workflow.
3. Click the **"Run workflow"** button (if available).

This allows you to manually rerun the workflow even without pushing to the `main` branch.

---

## 3. **Creating the Kubernetes resource** (Deployment, Service, etc.) to deploy the Flask application in your cluster.

---

### 1. **Setup Your Terraform Configuration**

First, ensure you have the required providers in your Terraform configuration.

#### a. **Terraform Providers**

You'll need the following providers:
- **Kubernetes Provider** (for deploying the app on Kubernetes).

Here's an example of how your `providers.tf` might look:

```hcl
# Provider for Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig file
}
```

---

### 2. **Create Kubernetes Resources Using Terraform**

After building and pushing the Docker image, we need to create the Kubernetes resources.

#### a. **Kubernetes Deployment Resource**

You can define the Kubernetes deployment for your Flask app using the `kubernetes_deployment` resource. Here’s how you can define it in your `main.tf` file:

```hcl
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
```

This will:
- Create a **deployment** for the Flask app with 3 replicas (pods).
- Pull the Docker image from DockerHub that was built earlier by GitHub Actions workflow.

#### b. **Kubernetes Service Resource**

Next, you need a **Kubernetes Service** to expose the Flask app within the cluster (and optionally outside the cluster). Here's how to create a `Service`:

```hcl
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
        port        = 3000             #Port the service exposes to the outside world
        target_port = 3000           #Port the app is running on within the container
        }

        type = "NodePort"
        }
}
```

This will expose your Flask application using a **NodePort** (accessible outside the Kubernetes cluster). You can later change `type = "LoadBalancer"` if you will be deploying on a cloud provider of your choice.

---

### 3. **Apply the Terraform Configuration**

Now that your Terraform configuration is ready, run the following commands to apply the changes and deploy the app to Kubernetes.

#### a. **Initialize Terraform**

Initialize Terraform to download the necessary providers and set up the working environment:

```bash
terraform init
```

#### b. **Validate the Configuration**

Ensure that there are no errors in your configuration before applying:

```bash
terraform validate
```

#### c. **Apply the Configuration**

Now, apply the Terraform configuration to create the Docker image, push it to the container registry, and deploy the Flask app to Kubernetes:

```bash
terraform apply
```

Terraform will ask for confirmation before applying the changes. Type `yes` to proceed.

---

#### d. **Check Pods and Services**

After the resources are created, you can check the status of your pods and services.

To check the pods:

```bash
kubectl get pods
```

To check the services:

```bash
kubectl get services
```

---

### 4. **Access the Flask Application**

After the resources are created, you can access your Flask application. If you're using **Minikube** or a local Kubernetes cluster, run the following to get the service URL:

```bash
minikube service flask-app-service --url
```

---

### 5. **Scaling and Updating the App**

To scale the number of replicas (pods) in your deployment, you can update the `replicas` value in your `kubernetes_deployment` resource and run `terraform apply` again:

```hcl
resource "kubernetes_deployment" "flask_app" {
  spec {
    replicas = 5  # Scale to 5 replicas
    ...
  }
}
```

To update the app with a new Docker image, build and push the new image, edit your code and push to the main branch of your git repository. This triggers the workflow and updates the default value of the ```flask-app-image``` variable resources in the `variable.tf` file. Then, re-run `terraform apply`.

---

### 7. **Cleaning Up**

If you want to delete the resources you've created (for example, to stop using the app), you can run:

```bash
terraform destroy --auto-apply
```

This will remove all the Kubernetes resources that were created by Terraform in your local environment.

---

### Final `main.tf` Example

Here’s what the full Terraform configuration (`main.tf`) might look like:

```hcl
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
```

Here's `provider.tf`:
```hcl
provider "kubernetes" {
    #Since we are using kubectl config file
    config_path = "~/.kube/config"
}
```

Here's `service.tf`:
```hcl
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
        port        = 3000             #Port the service exposes to the outside world
        target_port = 3000           #Port the app is running on within the container
        }

        type = "NodePort"
        }
}
```

Here's `variables.tf`:
```hcl
variable "flask_app_image" {
    description = "Docker image for Flask app"
    type        = string
    default     = "dockerusername/flask-app:6"
}

variable "replicas" {
    description = "Number of replicas for the Flask app"
    type        = number
    default     = 2
}
```

---

### Conclusion

You’ve now fully automated the process of deploying your Flask app to Kubernetes using **Terraform**! 🎉

This includes:
- Building and pushing the Docker image using GitHub Actions.
- Deploying the app using Kubernetes Deployment and Service resources.
- Managing the app with Terraform for easier scaling and updates.
