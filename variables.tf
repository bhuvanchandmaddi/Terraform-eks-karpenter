variable "cluster_name" {
  default     = "bmaddi-karpenter"
  description = "The name of the EKS cluster"
}

variable "vpc_cidr_block" {
  # default     = "10.0.0.0/16"
  description = "The CIDR of the vpc"
}

variable "aws_region" {
  default     = "us-east-1"
  description = "The aws region where you want to create the eks cluster"
}

variable "pulic_subnets_cidrs" {
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Cidr's of public subnets"
}
variable "private_subnets_cidrs" {
  type        = list(any)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  description = "Cidr's of private subnet"
}

variable "pulic_subnets_azs" {
  type        = list(any)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "Availability zone's of public subnets"
}
variable "private_subnets_azs" {
  type        = list(any)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "Avaiability Zone's of private subnet"
}

variable "env" {
  type        = string
  description = "Environment to Create ( dev/qa/prod )"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}


variable "retention_day" {
  description = "Specifies the number of days you want to retain log events"
}


variable "eks_version" {
  type        = string
  description = "Which version of EKS to create"
}

variable "node_group_name" {
  type        = string
  description = "The name of node group you want to create"
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU."
  type        = string
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 20."

}

variable "instance_types" {
  type        = list(string)
  description = "Set of instance types associated with the EKS Node Group."
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in private subnet"

}

variable "node_max_size" {
  description = "Maximum number of worker nodes in private subnet."

}

variable "node_min_size" {
  description = "Minimum number of worker nodes in private subnet."

}

variable "ec2_ssh_key_name_eks_nodes" {
  type        = string
  description = "Name of Key Pair used to login to the nodes"
}

variable "AWS_ACCESS_KEY" {

}

variable "AWS_SECRET_KEY" {

}

variable "region" {
}


variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.22.6-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.11.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.3"
    },
  ]
}





