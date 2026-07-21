#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

AWS_REGION="${AWS_REGION:-eu-north-1}"
export AWS_REGION

if [ -f ./kubeconfig ]; then
  export KUBECONFIG=./kubeconfig
  echo "==> Deleting Kubernetes resources"
  kubectl delete -f k8s/ --ignore-not-found=true || true
fi

echo "==> Destroying EKS infrastructure"
cd terraform
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || true)
terraform destroy -auto-approve
cd ..

if [ -n "$ECR_URL" ]; then
  echo "==> Removing local Docker image"
  docker rmi "$ECR_URL:latest" 2>/dev/null || true
fi

rm -f kubeconfig
rm -rf terraform/.terraform terraform/terraform.tfstate terraform/terraform.tfstate.backup terraform/.terraform.lock.hcl

echo "==> Cleanup complete"
