data "template_file" "helm-install" {
  template = <<EOF
  set -e
  curl -LO https://git.io/get_helm.sh
  chmod 700 get_helm.sh
 ./get_helm.sh
  EOF
}
resource "null_resource" "install_configs" {
  triggers = {
    run = "${uuid()}"
  }
  provisioner "local-exec" {
    command = <<EOH
      echo "Installing kubectl............."
      curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      echo "Installing Helm..............."
      ${data.template_file.helm-install}
      EOH

  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}
resource "null_resource" "helm_init" {
  depends_on = ["kubernetes_service_account.tiller", "null_resource.install_configs"]
  triggers = {
    run = uuid()
  }
  provisioner "local-exec" {
    environment = {
      KUBE_CONFIG_MAP_RENDERED = module.eks.kubeconfig
    }
    command = <<EOH
    echo "$KUBE_CONFIG_MAP_RENDERED" > kube_config.yaml
    export KUBECONFIG=$PWD/kube_config.yaml
    helm init --service-account tiller --wait
    EOH
  }
}