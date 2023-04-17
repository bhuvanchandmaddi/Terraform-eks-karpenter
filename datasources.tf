# data "aws_vpc" "vpc" {
#   #id = aws_vpc.main.id
#   tags = {
#     Name = "${var.vpc_name}"
#   }
#   # depends_on = [aws_vpc.main]
# }

# data "aws_subnets" "private" {
#   filter {
#     name   = "Name"
#     values = ["terraform-${var.cluster_name}-private-subnet-*"]
#   }

#   tags = {
#     subnets = "private"
#   }
#   # depends_on = [aws_subnet.private_subnets]
# }

# data "aws_subnets" "public" {
#   filter {
#     name   = "Name"
#     values = ["terraform-${var.cluster_name}-public-subnet-*"]
#   }

#   tags = {
#     subnets = "public"
#   }
#   #depends_on = [aws_subnet.public_subnets]
# }

# data "aws_subnet" "public_subnets" {
#   for_each = toset(data.aws_subnets.public.ids)
#   id       = each.value
#   #depends_on = [aws_subnet.public_subnets]
# }

# data "aws_subnet" "private_subnets" {
#   for_each = toset(data.aws_subnets.private.ids)
#   id       = each.value
#   #depends_on = [aws_subnet.private_subnets]
# }


# To get the AWS Account ID, User ID, and ARN in which Terraform is authorized.

# data "aws_vpc" "vpc" {
#   id = aws_vpc.main.id
#   tags = {
#     Name = "${var.vpc_name}"
#   }
#   depends_on = [aws_vpc.main]
# }


# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = ["${aws_vpc.main.id}"]
#   }

#   tags = {
#     subnets = "private"
#   }
#   depends_on = [aws_subnet.private_subnets]
# }


# data "aws_subnets" "public" {
#   filter {
#     name   = "vpc-id"
#     values = ["${aws_vpc.main.id}"]
#   }

#   tags = {
#     subnets = "public"
#   }
#   depends_on = [aws_subnet.public_subnets]
# }

# data "aws_subnet" "public_subnets" {
#   for_each   = toset(data.aws_subnets.public.ids)
#   id         = each.value
#   depends_on = [aws_subnet.public_subnets]
# }

# data "aws_subnet" "private_subnets" {
#   for_each   = toset(data.aws_subnets.private.ids)
#   id         = each.value
#   depends_on = [aws_subnet.private_subnets]
# }


data "aws_caller_identity" "current" {}

# data "aws_iam_role" "NodeGroupRole" {
#   name = "EKSNodeGroupRole_v2"

#   depends_on = [aws_eks_cluster.eks-cluster , aws_eks_node_group.node-group-private , aws_iam_role.NodeGroupRole  ]
# }


data "aws_iam_role" "alb_ingress" {
  name       = "${var.cluster_name}-alb-ingress"
  depends_on = [aws_iam_role.alb_ingress, aws_iam_role_policy_attachment.load-balancer-policy-role]
}


data "aws_eks_cluster" "cluster" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
}

data "aws_iam_openid_connect_provider" "openid" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
