data "azurerm_resource_group" "current" {
  name = var.resource_group
}

resource "azurerm_kubernetes_cluster" "current" {
  name                = var.metadata_name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  dns_prefix          = var.dns_prefix

  role_based_access_control {
    enabled = true
  }

  default_node_pool {
    name = var.default_node_pool_name
    type = var.default_node_pool_type

    enable_auto_scaling = var.default_node_pool_enable_auto_scaling

    # set min and max count only if autoscaling is _enabled_
    min_count = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null

    # set node count only if auto scaling is _disabled_
    node_count = var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count

    vm_size         = var.default_node_pool_vm_size
    os_disk_size_gb = var.default_node_pool_os_disk_size_gb
    
    vnet_subnet_id = var.vnet_subnet_id
    max_pods       = var.max_pods
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_plugin == "azure" ? "azure" : "calico"

    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr = var.service_cidr
    dns_service_ip = var.dns_service_ip
    pod_cidr = var.network_plugin == "azure" ? null : "10.244.0.0/16"
  }

  service_principal {
    client_id     = azuread_application.current.application_id
    client_secret = azuread_service_principal_password.current.value
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.current.id
    }
  }

  tags = var.metadata_labels
}

data "external" "aks_nsg_id" {
  program = [
    "bash",
    "${path.root}/scripts/aks_nsg_name.sh"
  ]

  query = {
    resource_group = "${azurerm_kubernetes_cluster.current.node_resource_group}"
  }
}
