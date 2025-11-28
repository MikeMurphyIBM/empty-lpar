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

# DATA SOURCE: Retrieve the ID of the specific 'Empty' image
data "ibm_pi_image" "empty_os_image" {
  # Choose one of the required empty deployment image names:
  # "AIX-EMPTY", "IBMI-EMPTY", "RHEL-EMPTY", or "SLES-EMPTY"
  pi_image_name = "IBMI-EMPTY" 
  pi_cloud_instance_id = "crn:v1:bluemix:public:power-iaas:dal10:a/21d74dd4fe814dfca20570bbb93cdbff:cc84ef2f-babc-439f-8594-571ecfcbe57a::"



# Get EXISTING PowerVS network
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = local.pvs_cloud_instance_guid
  pi_network_id        = var.existing_network_id
}


# Create Empty IBMi LPAR Clone
resource "ibm_pi_instance" "empty_lpar" {
  pi_cloud_instance_id = local.pvs_cloud_instance_guid

  pi_instance_name = var.pvs_instance_name
  pi_image_id      = var.pvs_ibmi_image_id

  pi_memory     = var.pvs_instance_memory
  pi_processors = var.pvs_instance_cores
  pi_proc_type  = "shared"


  # Use existing SSH key instead of creating one
  pi_key_pair_name = var.existing_key_name

  # Attach to existing PowerVS network
  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }

  pi_pin_policy = "none"
}


