AWS_ACCESS_KEY = ""
AWS_SECRET_KEY = ""
region         = "us-east-1"


#cluster_name   = bmaddi-karpenter
vpc_cidr_block = "10.0.0.0/16"

env                        = "dev"
vpc_name                   = "terraform-vpc"
retention_day              = 7
eks_version                = "1.24"
node_group_name            = "terraform-eks-nodegroup"
ami_type                   = "BOTTLEROCKET_x86_64"
disk_size                  = 20
instance_types             = ["t3.xlarge"]
node_desired_size          = 1
node_max_size              = 4
node_min_size              = 1
ec2_ssh_key_name_eks_nodes = "sample_key"
