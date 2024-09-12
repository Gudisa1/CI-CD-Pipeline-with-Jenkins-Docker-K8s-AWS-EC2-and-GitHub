---

# CI/CD Pipeline with Jenkins, Docker, Kubernetes, and AWS EC2

This project demonstrates a fully automated **CI/CD pipeline** for building, testing, and deploying a Flask-based web application using **Jenkins**, **Docker**, **Kubernetes**, and **AWS EC2**. The pipeline is triggered by commits pushed to a **GitHub** repository and ensures continuous integration and delivery of the application to a Kubernetes cluster.

---

## CI/CD Pipeline Architecture

Below is the architecture diagram that illustrates the pipeline workflow:

![CI/CD Pipeline Diagram](path/to/diagram.png) <!-- Replace with actual diagram URL -->

### Workflow Overview

1. **Developer Pushes Code to GitHub**: The pipeline is triggered when a developer pushes new code to the GitHub repository.
2. **Jenkins CI**: Jenkins automatically pulls the latest code and runs build and test jobs.
3. **Docker Build**: The application is packaged into a Docker image.
4. **Docker Push to Registry**: The Docker image is pushed to **Docker Hub**.
5. **Kubernetes Deployment**: Jenkins triggers the deployment of the Docker container to a Kubernetes cluster running on AWS.
6. **Monitoring & Scaling**: Kubernetes manages scaling, load balancing, and monitoring of the application.

---

## Tools and Technologies Used

### 1. **GitHub**
   - **Purpose**: Stores source code and manages version control.
   - **Webhook**: Triggers Jenkins on each code push.
   
### 2. **AWS EC2**
   - **Purpose**: Hosts the Jenkins server and runs Docker containers.
   - **Configuration**: The EC2 instance runs **Ubuntu 22.04** and is set up with public SSH access and security rules.

### 3. **Jenkins**
   - **Purpose**: Automates the CI/CD pipeline and handles integration and deployment tasks.
   - **Plugins**: Jenkins uses plugins such as **Git**, **Docker**, and **Kubernetes** to manage the pipeline.
   - **Pipeline Definition**: A `Jenkinsfile` defines the stages of the pipeline, including building, testing, and deploying the application.

### 4. **Docker**
   - **Purpose**: Containerizes the application to ensure consistency across environments.
   - **Docker Hub**: Used as a Docker image registry where Jenkins pushes the built images.

### 5. **Kubernetes (K8s)**
   - **Purpose**: Manages the deployment of Docker containers, providing features such as scaling, load balancing, and automatic restart of unhealthy containers.
   - **Kubernetes Cluster**: Deployed on AWS for hosting the Flask application in a scalable environment.

---

## Prerequisites

Before setting up the pipeline, ensure the following tools and configurations are ready:

- **GitHub Account**: To store and version control your application.
- **AWS Account**: To launch an EC2 instance and set up a Kubernetes cluster.
- **Docker Hub Account**: To host Docker images.
- **Jenkins Server**: Running on an AWS EC2 instance with required plugins.
- **Kubernetes Cluster**: A working K8s cluster (e.g., **EKS**, **Minikube**, or **Kops**).

---

## Setup Instructions

### 1. **AWS EC2 Instance Setup**

- Launch an **AWS EC2** instance with the following specifications:
  - **Ubuntu 22.04** as the operating system.
  - At least **t2.medium** instance type for better performance.
  - Open necessary ports in the security group (e.g., **port 8080** for Jenkins and **port 22** for SSH access).
  - Connect to the EC2 instance via SSH.

### 2. **Jenkins Setup on EC2**

- **Install Jenkins**:
  1. Update your package index:
     ```bash
     sudo apt update
     ```
  2. Install Jenkins and Java:
     ```bash
     sudo apt install openjdk-11-jdk jenkins
     ```
  3. Start and enable the Jenkins service:
     ```bash
     sudo systemctl start jenkins
     sudo systemctl enable jenkins
     ```

- **Access Jenkins**: Open your browser and access Jenkins at `http://<your-EC2-public-IP>:8080`.

- **Install Plugins**:
  - Install the following plugins from the Jenkins dashboard: **Git**, **Docker Pipeline**, **Kubernetes**, and **Blue Ocean**.

### 3. **Docker Setup on EC2**

- **Install Docker**:
  ```bash
  sudo apt install docker.io
  ```
- **Start Docker**:
  ```bash
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- **Configure Docker Permissions**: Allow Jenkins to run Docker commands without `sudo`.
  ```bash
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
  ```

### 4. **Configure Jenkins Pipeline (Jenkinsfile)**

Create a `Jenkinsfile` in the root of your GitHub repository:

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-repo-url.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("your-dockerhub-repo/flask-app:${env.BUILD_ID}")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
            }
        }
    }
}
```

### 5. **Docker Hub Integration**

- Log in to Docker Hub using Jenkins credentials:
  1. Create a **Docker Hub** account and repository.
  2. Add Docker Hub credentials to Jenkins (`dockerhub-credentials` in Jenkinsfile).

### 6. **Kubernetes Deployment**

- Set up the **Kubernetes Cluster** using AWS (e.g., **EKS**) or a local K8s cluster like **Minikube**.
- Define Kubernetes deployment and service configurations in a `k8s/deployment.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: your-dockerhub-repo/flask-app:latest
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  type: LoadBalancer
  selector:
    app: flask-app
  ports:
  - port: 80
    targetPort: 5000
```

### 7. **Trigger the Pipeline**

- Push code to your GitHub repository to automatically trigger the Jenkins pipeline.
- Jenkins will build the Docker image, push it to Docker Hub, and deploy the container to your Kubernetes cluster.

---

## Monitoring and Scaling

- **Kubernetes Dashboard**: Use the Kubernetes dashboard to monitor deployments, pods, and services.
- **Scaling**: Kubernetes manages scaling automatically. You can scale the number of pods by editing the `replicas` field in the deployment configuration.

---

## Troubleshooting

1. **Jenkins Not Triggering on Push**: Verify the GitHub webhook is correctly configured.
2. **Docker Permissions Issues**: Ensure Jenkins has the necessary permissions to run Docker commands.
3. **Kubernetes Deployment Failures**: Check the `kubectl` logs for any errors during deployment.

---

## Future Enhancements

- **Implement Blue-Green Deployments**: Add support for blue-green deployment strategies in Kubernetes.
- **Automated Testing**: Integrate automated testing in the pipeline before deploying to Kubernetes.
- **Advanced Monitoring**: Set up Prometheus and Grafana for monitoring the application and infrastructure.

---

