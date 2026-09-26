# EKS Python Demo

[![CI](https://github.com/tusharswain/eks-python-demo/actions/workflows/ci.yml/badge.svg)](https://github.com/tusharswain/eks-python-demo/actions/workflows/ci.yml)

A minimal Flask app deployed to **Amazon EKS** with a managed node group and exposed through a Kubernetes `LoadBalancer` Service.

## What it does

- Builds a Docker image for a small Python Flask app.
- Pushes it to Amazon ECR.
- Creates an EKS cluster, VPC, subnets, IAM roles, and a managed node group using Terraform.
- Deploys the app with `kubectl` as a Kubernetes Deployment + Service.
- Exposes the app on an AWS Load Balancer created by the Kubernetes service.

## Architecture

```
Browser
   |
   v
AWS LoadBalancer (created by K8s Service)
   |
   v
EKS Node (managed node group)
   |
   v
Flask Pod(s)
```

## Files

- `app/` — Flask app and dependencies.
- `Dockerfile` — container image build.
- `terraform/` — VPC, EKS cluster, node group, ECR repository.
- `k8s/` — Kubernetes Deployment and Service manifests.
- `deploy.sh` — full deploy: ECR → build → EKS → kubectl.
- `cleanup.sh` — deletes K8s resources and destroys all AWS infrastructure.

## Prerequisites

- AWS CLI configured.
- `docker`, `terraform`, `kubectl` installed.
- AWS region default: `eu-north-1` (override with `AWS_REGION`).

## Quick start

```bash
cd eks_python_demo
export AWS_REGION=eu-north-1
./deploy.sh
```

When it finishes, open the printed URL:

```text
http://<load-balancer-hostname>
http://<load-balancer-hostname>/health
```

## Cleanup

```bash
./cleanup.sh
```

## ECS vs EKS

| Area | ECS | EKS |
|---|---|---|
| What it is | AWS-native container orchestration | Managed Kubernetes on AWS |
| Control plane | AWS-managed ECS backend | AWS-managed Kubernetes API |
| Compute | Fargate or EC2 | Fargate profiles or managed EC2 nodes |
| Core objects | Tasks, services, clusters | Pods, deployments, services, ingress |
| Networking | VPC/ENI per task | VPC CNI gives each pod an IP |
| Load balancing | ALB/NLB target groups | Service `LoadBalancer` or Ingress + controller |
| IAM | Task execution role, task role | Cluster role, node role, IRSA |
| Scaling | Service auto scaling | HPA, cluster autoscaler |
| Tooling | AWS CLI, Console, Terraform | `kubectl`, `helm`, Terraform |
| Portability | AWS-only | Kubernetes workloads can run anywhere |
| Learning curve | Lower | Higher |
| Cost | Lower for simple apps | Higher (control plane + nodes) |

## Notes

- This demo uses a public `LoadBalancer` Service. For ALB/HTTP path-based routing you would add the AWS Load Balancer Controller and an `Ingress` resource.
- The managed node group runs in public subnets to keep the demo small (no NAT gateways).
