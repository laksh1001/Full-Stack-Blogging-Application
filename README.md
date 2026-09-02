# 🚀 Production-Grade DevSecOps CI/CD Pipeline & SRE Observability Platform

An end-to-end, enterprise-ready DevSecOps pipeline and Kubernetes deployment featuring automated security scanning, artifact lifecycle governance, custom DNS routing with SSL/TLS termination, and synthetic SRE monitoring.

---

## 📑 Table of Contents
- [Architecture Overview](#-architecture-overview)
- [Tech Stack & Tools](#-tech-stack--tools)
- [Pipeline Stages](#-pipeline-stages)
- [Infrastructure & Cloud Deployment](#-infrastructure--cloud-deployment)
- [Observability & SRE Monitoring](#-observability--sre-monitoring)
- [Prerequisites](#-prerequisites)
- [Step-by-Step Implementation Guide](#-step-by-step-implementation-guide)
  - [1. Infrastructure Provisioning](#1-infrastructure-provisioning)
  - [2. Jenkins Pipeline Configuration](#2-jenkins-pipeline-configuration)
  - [3. Kubernetes & AWS Networking Setup](#3-kubernetes--aws-networking-setup)
  - [4. Prometheus & Blackbox Monitoring Setup](#4-prometheus--blackbox-monitoring-setup)
- [Teardown & Cleanup](#-teardown--cleanup)

---

## 🏗 Architecture Overview

```text
[ Developer Git Push ]
        │
        ▼
[ Jenkins Declarative Pipeline ]
  ├── 1. Declarative Tool Install (Maven, JDK)
  ├── 2. Git Checkout & Source Validation
  ├── 3. Build & Unit Testing (Maven)
  ├── 4. Static Code Analysis (SonarQube Quality Gate)
  ├── 5. Filesystem Security Scan (Trivy FS)
  ├── 6. Artifact Publishing (Sonatype Nexus Repository)
  ├── 7. Docker Image Build & Tagging
  ├── 8. Container Vulnerability Scan (Trivy Image)
  └── 9. Push Image to Registry (Docker Hub)
        │
        ▼
[ AWS Kubernetes (EKS) Deployment ]
  ├── Kubernetes Workloads (Deployment, Pods in webapps Namespace)
  ├── AWS Load Balancer (ELB / ALB)
  ├── SSL/TLS Termination (AWS ACM Certificate)
  └── Custom Domain DNS Routing (AWS Route 53: https://www.nklakshxinfo.xyz)
        │
        ▼
[ SRE Telemetry & Observability Stack ]
  ├── Prometheus (Scraping local & blackbox targets)
  ├── Prometheus Blackbox Exporter (HTTP/2xx probes, TLS latency, SSL expiry)
  └── Grafana (Real-time telemetry dashboards & latency visualization)

```

---

## 🛠 Tech Stack & Tools

* **Source Code Management:** Git, GitHub
* **CI/CD Orchestration:** Jenkins (Declarative Pipelines)
* **Build & Package Management:** Maven, Java / Spring Boot
* **Code Quality & Security:** SonarQube (Quality Gate), Trivy (SAST & Container Image Scanning)
* **Artifact Management:** Sonatype Nexus Repository Manager
* **Containerization:** Docker, Docker Hub
* **Container Orchestration:** Kubernetes / AWS EKS
* **Cloud & Networking (AWS):** EC2, VPC, Application Load Balancer, Route 53, AWS Certificate Manager (ACM)
* **Observability & SRE:** Prometheus, Prometheus Blackbox Exporter, Grafana

---

## 🔄 Pipeline Stages

| Stage | Tool | Description |
| --- | --- | --- |
| **Git Checkout** | Git | Clones the latest branch commit. |
| **Compile & Test** | Maven | Compiles source code and executes automated unit test suites. |
| **Code Quality** | SonarQube | Checks code smells, bugs, vulnerabilities, and enforces Quality Gate. |
| **Trivy FS Scan** | Trivy | Performs static security analysis on dependencies and file system. |
| **Publish Artifact** | Nexus | Archives release artifacts (`.jar`, `.pom`) into Nexus Maven repository. |
| **Docker Build** | Docker | Builds optimized container images with dynamic build numbering tags. |
| **Trivy Image Scan** | Trivy | Scans Docker image layers for high/critical CVE vulnerabilities. |
| **Docker Push** | Docker Hub | Authenticates and publishes verified images to Docker Hub registry. |

---

## ☁️ Infrastructure & Cloud Deployment

1. **Kubernetes Cluster (`webapps` namespace):** Runs the containerized application replicas behind a managed Kubernetes Service.
2. **Traffic Encryption (HTTPS):** Configured with AWS Certificate Manager (ACM) to handle automated TLS/SSL termination directly at the AWS Load Balancer.
3. **DNS Mapping:** Configured AWS Route 53 alias records directing traffic from custom domain `www.nklakshxinfo.xyz` to the AWS Application Load Balancer.

---

## 📊 Observability & SRE Monitoring

* **Prometheus:** Collects real-time metrics and target scrape metrics on port `9090`.
* **Blackbox Exporter:** Executes synthetic blackbox probes on port `9115` verifying `http_2xx` responses, DNS resolution time, TCP connection speed, and TLS handshake latencies.
* **Grafana Dashboard:** Visualizes uptime availability, probe durations (~20–30ms response time), HTTP status codes, and SSL certificate expiration countdowns.

---

## 📋 Prerequisites

* AWS Account with IAM permissions for EC2, VPC, Route 53, and EKS.
* Registered domain name (configured in Route 53).
* Docker Hub and Sonatype Nexus account credentials.
* Configured EC2 instances for Jenkins, SonarQube, Nexus, and Monitoring.

---

## 🚀 Step-by-Step Implementation Guide

### 1. Infrastructure Provisioning

Provision AWS EC2 instances with appropriate security groups:

* **Jenkins:** Port `8080`, SSH `22`
* **SonarQube:** Port `9000`
* **Nexus:** Port `8081`
* **Monitoring Server:** Prometheus `9090`, Grafana `3000`, Blackbox Exporter `9115`

### 2. Jenkins Pipeline Configuration

Add credentials in Jenkins (`docker-cred`, `nexus-cred`, `sonar-token`) and set up the declarative `Jenkinsfile`:

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven-3.9.0'
        jdk 'JDK-17'
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/laksh1001/Full-Stack-Blogging-Application.git'
            }
        }
        stage('Compile & Test') {
            steps {
                sh 'mvn clean test'
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --format table -o trivy-fs-report.html .'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Build & Release Artifacts') {
            steps {
                sh 'mvn clean deploy -DskipTests'
            }
        }
        stage('Docker Build & Scan') {
            steps {
                sh 'docker build -t lakshman1001/blogging-application:${BUILD_NUMBER} .'
                sh 'trivy image lakshman1001/blogging-application:${BUILD_NUMBER}'
            }
        }
        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo $DOCKER_PASSWORD \vert{} docker login -u$DOCKER_USERNAME --password-stdin'
                    sh 'docker push lakshman1001/blogging-application:${BUILD_NUMBER}'
                }
            }
        }
    }
}

```

### 3. Kubernetes & AWS Networking Setup

Deploy your Kubernetes manifest with AWS LoadBalancer annotations:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blogging-app-deployment
  namespace: webapps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blogging-app
  template:
    metadata:
      labels:
        app: blogging-app
    spec:
      containers:
      - name: blogging-app
        image: lakshman1001/blogging-application:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: blogging-app-service
  namespace: webapps
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR-CERT-UUID"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8080
  selector:
    app: blogging-app

```

### 4. Prometheus & Blackbox Monitoring Setup

Configure `prometheus.yml` on your monitoring server:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://www.nklakshxinfo.xyz
        - https://prometheus.io
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115

```

Start the services in the background:

```bash
# Start Blackbox Exporter
cd ~/blackbox && nohup ./blackbox_exporter > blackbox.log 2>&1 &

# Start Prometheus
cd ~/prometheus && nohup ./prometheus > prometheus.log 2>&1 &

```

Import Grafana Dashboard ID **`7587`** to observe live synthetic probes and SSL metrics.

---

## 🧹 Teardown & Cleanup

To prevent ongoing AWS infrastructure costs:

1. **Delete Kubernetes LoadBalancer Service:**
```bash
kubectl delete svc blogging-app-service -n webapps
kubectl delete namespace webapps

```


2. **Delete EKS Cluster (if managed via eksctl):**
```bash
eksctl delete cluster --name <cluster-name> --region <region>

```


3. **Terminate EC2 Instances:** Terminate Jenkins, Nexus, SonarQube, and Monitoring EC2 nodes via the AWS Console.
4. **Release Elastic IPs & Delete NAT Gateways** to ensure zero residual cloud spend.

---

## 👤 Author

* **Lakshman** - [GitHub Profile] :- https://github.com/laksh1001/Full-Stack-Blogging-Application

```

```
