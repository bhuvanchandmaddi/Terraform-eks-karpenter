resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.pulic_subnets_azs, count.index)
  cidr_block              = element(var.pulic_subnets_cidrs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "terraform-${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = "${var.cluster_name}"
    "kubernetes.io/role/elb"                    = 1
  }
}
resource "aws_subnet" "private_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.private_subnets_azs, count.index)
  cidr_block              = element(var.private_subnets_cidrs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "terraform-${var.cluster_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = "${var.cluster_name}"
    "kubernetes.io/role/internal-elb"           = 1
  }
}
