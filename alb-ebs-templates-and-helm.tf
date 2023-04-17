## TEMPLATE FILES ##
data "template_file" "alb-ingress-values" {
  template = <<EOF
       replicaCount: 1
       vpcId: "${aws_vpc.main.id}"
       clusterName: "${var.cluster_name}"
       ingressClass: alb
       createIngressClassResource: true
  
       region: "${var.region}"
       resources:
          requests:
             memory: 256Mi
             cpu: 100m
          limits:
             memory: 512Mi
             cpu: 1000m
  EOF
}

data "template_file" "ebs-csi-driver-values" {
  template = <<EOF
    controller:
      region: "${var.region}"
      replicaCount: 1
      k8sTagClusterId: "${var.cluster_name}" 
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
         maxUnavailable: 1
      resources:
        requests:
          cpu: 10m
          memory: 40Mi
        limits:
           cpu: 100m
           memory: 256Mi
      serviceAccount:
        create: true
        name: ebs-csi-controller-sa
        annotations: 
            eks.amazonaws.com/role-arn: "${aws_iam_role.ebs-csi.arn}"
    storageClasses: 
     - name: ebs-sc
       annotations:
          storageclass.kubernetes.io/is-default-class: "true"
  EOF
}

## END OF TEMPLATE FILES ##

## KUBERENETS RESOURCES FOR ALB INGRESS CONTROLLER ##

resource "kubernetes_service_account" "aws-load-balancer-controller-service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.alb_ingress.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  automount_service_account_token = true
  depends_on                      = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
}


resource "kubernetes_secret" "aws-load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name"      = "aws-load-balancer-controller"
      "kubernetes.io/service-account.namespace" = "kube-system"
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [kubernetes_service_account.aws-load-balancer-controller-service-account, aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
}


resource "kubernetes_cluster_role" "aws-load-balancer-controller-cluster-role" {
  depends_on = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "aws-load-balancer-controller-cluster-role-binding" {
  depends_on = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private]
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.aws-load-balancer-controller-cluster-role.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.aws-load-balancer-controller-service-account.metadata[0].name
    namespace = kubernetes_service_account.aws-load-balancer-controller-service-account.metadata[0].namespace
  }
}

## END OF K8S RESOURCES FOR ALB INGRESS CONTROLLER ##

## HELM RELEASES

resource "helm_release" "alb-ingress-controller" {

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-group-private,
    kubernetes_cluster_role_binding.aws-load-balancer-controller-cluster-role-binding,
    kubernetes_service_account.aws-load-balancer-controller-service-account,
    kubernetes_secret.aws-load-balancer-controller,
    helm_release.karpenter,
  kubectl_manifest.karpenter-provisioner]

  name       = "alb-ingress-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.7"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  values     = [data.template_file.alb-ingress-values.rendered]

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws-load-balancer-controller-service-account.metadata[0].name
  }
}

resource "helm_release" "aws-ebs-csi-driver" {
  depends_on       = [aws_eks_cluster.eks-cluster, aws_eks_node_group.node-group-private, helm_release.karpenter, kubectl_manifest.karpenter-provisioner, aws_iam_role.ebs-csi]
  name             = "aws-ebs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart            = "aws-ebs-csi-driver"
  namespace        = "kube-system"
  create_namespace = true
  values           = [data.template_file.ebs-csi-driver-values.rendered]
}
