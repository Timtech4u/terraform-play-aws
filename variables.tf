
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster"
  default     = "practice-cluster"
}

variable "private_subnets" {
  type        = list
  description = "List of private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type        = list
  description = "List of public subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "iam_username" {
  type        = string
  description = "username for the iam user"
  default     = "timothy.olaleke"
}
