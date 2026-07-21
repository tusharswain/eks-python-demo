#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

AWS_REGION="${AWS_REGION:-eu-north-1}"
export AWS_REGION

echo "==> Step 1: Creating ECR repository"
cd terraform
terraform init
terraform apply -target=aws_ecr_repository.app -auto-approve
ECR_URL=$(terraform output -raw ecr_repository_url)
cd ..

echo "==> Step 2: Building and pushing Docker image"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${ECR_URL%/*}"
docker build -t "$ECR_URL:latest" .
docker push "$ECR_URL:latest"

echo "==> Step 3: Creating EKS cluster and managed node group"
cd terraform
terraform apply -auto-approve
CLUSTER_NAME=$(terraform output -raw cluster_name)
cd ..

echo "==> Step 4: Configuring kubectl"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION" --kubeconfig ./kubeconfig
export KUBECONFIG=./kubeconfig

echo "==> Step 5: Deploying app to EKS"
sed "s|IMAGE_PLACEHOLDER|$ECR_URL:latest|" k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/service.yaml

echo "==> Step 6: Waiting for LoadBalancer hostname"
for i in {1..60}; do
  HOSTNAME=$(kubectl get svc eks-python-demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [ -n "$HOSTNAME" ]; then
    echo "==> Done!"
    echo "    Open: http://$HOSTNAME"
    echo "    (Wait 60-90 seconds for pods to start and pass health checks.)"
    exit 0
  fi
  echo "Waiting for load balancer... ($i/60)"
  sleep 10
done

echo "Timed out waiting for load balancer."
exit 1
