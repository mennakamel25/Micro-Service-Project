# 🚀 Micro-Service-Project

A production-grade, end-to-end DevOps pipeline for deploying the **OpenTelemetry Demo** microservices application on **AWS EKS** using modern GitOps practices.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Microservices](#microservices)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Provision Infrastructure with Terraform](#1-provision-infrastructure-with-terraform)
  - [2. Create ECR Repositories](#2-create-ecr-repositories)
  - [3. CI/CD Pipeline — GitHub Actions](#3-cicd-pipeline--github-actions)
  - [4. Deploy with ArgoCD (GitOps)](#4-deploy-with-argocd-gitops)
- [GitOps Flow](#gitops-flow)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project demonstrates a complete DevOps workflow for a cloud-native microservices application. It covers everything from infrastructure provisioning to continuous delivery:

- **Infrastructure as Code** with Terraform to spin up an AWS EKS cluster
- **Containerization** with Docker and image storage on AWS ECR
- **CI/CD** with GitHub Actions to build, tag, and push Docker images automatically
- **GitOps Deployment** with ArgoCD and Helm to keep the Kubernetes cluster in sync with this repository
- **Observability** baked in via the OpenTelemetry Demo application

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Developer                            │
│                    git push → GitHub                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               GitHub Actions (CI/CD)                        │
│  Build Docker images → Push to AWS ECR → Update Helm values │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               ArgoCD (GitOps Controller)                    │
│     Watches repo → Syncs Helm chart → Deploys to EKS        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  AWS EKS Cluster                            │
│   (Provisioned by Terraform)                                │
│                                                             │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│   │ frontend │  │ checkout │  │ payment  │  │ cart     │  │
│   └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│   │  kafka   │  │ postgres │  │  redis   │  │  ...     │  │
│   └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Cloud Provider | AWS (EKS, ECR, IAM, VPC) |
| Infrastructure as Code | Terraform |
| Container Runtime | Docker |
| Container Registry | AWS ECR |
| Orchestration | Kubernetes (EKS) |
| Package Manager | Helm |
| CI/CD | GitHub Actions |
| GitOps | ArgoCD |
| Observability | OpenTelemetry |
| Languages | TypeScript, Python, Go, Java, C# |

---

## Repository Structure

```
Micro-Service-Project/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipelines
├── helm/
│   └── otel-demo/          # Helm chart for the OpenTelemetry Demo app
├── src/                    # Microservice source code
├── terraform/              # AWS infrastructure definitions (EKS, VPC, etc.)
├── test/                   # Integration / end-to-end tests
├── argocd-app.yaml         # ArgoCD Application manifest
└── bash.sh                 # Helper script to create ECR repositories
```

---

## Microservices

The application consists of the following services, each with its own Docker image pushed to AWS ECR:

| Service | Description |
|---|---|
| `frontend` | Web UI served to end users |
| `frontend-proxy` | Envoy proxy in front of the frontend |
| `checkout` | Checkout orchestration service |
| `cart` | Shopping cart service |
| `payment` | Payment processing service |
| `product-catalog` | Product listing and details |
| `recommendation` | Product recommendation engine |
| `shipping` | Shipping cost calculation |
| `currency` | Currency conversion service |
| `email` | Email notification service |
| `ad` | Advertisement service |
| `accounting` | Accounting/revenue tracking |
| `fraud-detection` | Fraud detection service |
| `quote` | Quote generation service |
| `load-generator` | Synthetic traffic generator |
| `image-provider` | Static image hosting |
| `flagd-ui` | Feature flag management UI |
| `kafka` | Message broker |
| `postgres` | Relational database |
| `opensearch` | Search and analytics engine |

---

## Prerequisites

Before getting started, make sure you have the following installed and configured:

- [AWS CLI](https://aws.amazon.com/cli/) — authenticated with appropriate permissions
- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.3
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) ≥ 3.x
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional but useful)
- [Docker](https://docs.docker.com/get-docker/)

---

## Getting Started

### 1. Provision Infrastructure with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates the AWS EKS cluster, VPC, node groups, IAM roles, and any other required resources.

After the cluster is ready, update your kubeconfig:

```bash
aws eks update-kubeconfig --name <cluster-name> --region us-west-2
```

### 2. Create ECR Repositories

Run the helper script to create one ECR repository per microservice:

```bash
chmod +x bash.sh
./bash.sh
```

This creates repositories in `us-west-2` for all 20 services. Repositories that already exist are safely skipped.

### 3. CI/CD Pipeline — GitHub Actions

The workflows in `.github/workflows/` automatically:

1. Trigger on a push to `main`
2. Build each service's Docker image
3. Push images to the corresponding AWS ECR repository
4. Update the image tags in the Helm chart values

Configure the following **GitHub Actions secrets** in your repository settings:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key |
| `AWS_REGION` | Target AWS region (e.g. `us-west-2`) |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID |

### 4. Deploy with ArgoCD (GitOps)

**Install ArgoCD on the cluster:**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Update the ArgoCD Application manifest** — edit `argocd-app.yaml` and replace the placeholder repo URL:

```yaml
source:
  repoURL: https://github.com/mennakamel25/Micro-Service-Project
```

**Apply the manifest:**

```bash
kubectl apply -f argocd-app.yaml
```

ArgoCD will now watch the `helm/otel-demo` directory and automatically sync any changes to the cluster, with `prune` and `selfHeal` enabled.

**Access the ArgoCD UI:**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080` in your browser. Retrieve the initial admin password with:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## GitOps Flow

```
Code change pushed to GitHub
        │
        ▼
GitHub Actions builds & pushes Docker images to ECR
        │
        ▼
Helm chart values updated in repository (new image tags)
        │
        ▼
ArgoCD detects drift between cluster state and Git
        │
        ▼
ArgoCD automatically syncs → rolling update on EKS
```

The cluster state is **always driven by Git** — no manual `kubectl apply` is needed after the initial setup.

---

## Screenshots

![ArgoCD Application Sync](Screenshot%20from%202026-05-15%2007-05-08.png)
![EKS Cluster Overview](Screenshot%20from%202026-05-15%2005-22-19.png)
![Infrastructure Provisioning](Screenshot%20from%202026-05-09%2022-42-48.png)

---

## Contributing

Contributions are welcome! Please fork the repository and open a pull request with your changes.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is open source. Feel free to use it as a reference for your own DevOps pipelines.

---

> Built with ❤️ by [mennakamel25](https://github.com/mennakamel25)
