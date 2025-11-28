# Resource Group
data "ibm_resource_group" "group" {
  name = "Default"
}


# Existing PowerVS workspace (returns CRN)
data "ibm_resource_instance" "pvs_workspace" {
  name = var.pvs_workspace_name
}

# Convert CRN → GUID (fixes malformed CRN errors)
locals {
  pvs_cloud_instance_guid = split(":", data.ibm_resource_instance.pvs_workspace.id)[7]
}



# Get EXISTING PowerVS network
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = local.pvs_cloud_instance_guid
  pi_network_id        = var.existing_network_id
}


# Create AIX LPAR Clone
resource "ibm_pi_instance" "clone" {
  pi_cloud_instance_id = local.pvs_cloud_instance_guid

  pi_instance_name = var.pvs_dr_instance_name
  pi_image_id      = var.pvs_aix_image_id

  pi_memory     = var.pvs_dr_instance_memory
  pi_processors = var.pvs_dr_instance_cores
  pi_proc_type  = "shared"

  pi_sys_type     = "s922"
  pi_storage_type = "tier3"

  # Use existing SSH key instead of creating one
  pi_key_pair_name = var.existing_key_name

  # Attach to existing PowerVS network
  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }

  pi_pin_policy = "none"
}


