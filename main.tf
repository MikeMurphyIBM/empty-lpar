# ======================================================================
# DATA SOURCES & LOOKUPS
# These blocks fetch IDs and details for existing resources (Workspace, Network, Image).
# ======================================================================

# 1. Retrieve the default Resource Group ID.
data "ibm_resource_group" "group" {
  name = "Default"
}

# 2. Retrieve the existing Power Virtual Server workspace instance details by name.
#    This resource returns a Cloud Resource Name (CRN).
data "ibm_resource_instance" "pvs_workspace" {
  name = var.pvs_workspace_name
}

locals {
  # Correct way to get the GUID (assuming index 7 is the GUID)
  pvs_cloud_instance_guid = element(split(":", data.ibm_resource_instance.pvs_workspace.id), 7)
}

# 4. CRITICAL: Retrieve the Image ID for the specialized 'IBMI-EMPTY' deployment.
#    Using this specific name instructs PowerVS to create a VM without a boot volume.
data "ibm_pi_image" "empty_os_image" {
  # Selects the specific image required for an empty deployment (no OS boot volume).
  pi_image_name        = "IBMI-EMPTY"
  pi_cloud_instance_id = local.pvs_cloud_instance_guid
}

# 5. Retrieve the existing PowerVS network details to attach the LPAR to.
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = local.pvs_cloud_instance_guid
  pi_network_id        = var.existing_network_id
}

# ======================================================================
# RESOURCE: IBM Power Virtual Server Instance (LPAR)
# ======================================================================

resource "ibm_pi_instance" "empty_lpar" {
  # Assign the LPAR to the target PowerVS workspace using the GUID.
  pi_cloud_instance_id = local.pvs_cloud_instance_guid
  pi_instance_name = var.pvs_instance_name

  # Stating argument for no OS
  pi_deployment_type = "VMNoStorage"

  # Define the policy: "affinity" ensures the volume is created in the same storage provider as the target object
  pi_storage_affinity = "affinity" 

  # Specify the object to base the affinity against
  pi_storage_affinity_instance = var.affinity_source_instance_id

  # This setting indicates that all volumes attached to this server must reside in the same storage pool
  # This is crucial for PVM instance snapshot, capture, and clone features
  pi_storage_pool_affinity = true 


  # Inject the ID of the 'IBMI-EMPTY' image retrieved via the data lookup.
  pi_image_id      = data.ibm_pi_image.empty_os_image.id
 
  
  # Define compute resources using input variables
  pi_memory     = var.pvs_instance_memory
  pi_processors = var.pvs_instance_cores
  pi_proc_type  = "shared" # Defines the processor type (e.g., shared, dedicated, capped)
  pi_sys_type   = "s1022" 
  pi_storage_type  = "tier1" 
  


  # Specify the pre-existing SSH key name for access after creation.
  pi_key_pair_name = var.existing_key_name

  # Attach the LPAR to the target network.
  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }

  # Set the pinning policy for server placement.
  pi_pin_policy = "none"
}


