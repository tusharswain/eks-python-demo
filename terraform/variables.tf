variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "eks-python-demo"
  validation {
    condition     = length(var.app_name) <= 15 && can(regex("^[a-z0-9-]+$", var.app_name))
    error_message = "app_name must be 15 characters or less and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.small"]
}
