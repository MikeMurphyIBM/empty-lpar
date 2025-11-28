variable "dr_pvs_region" {
  description = "Where to deploy the DR environment"
  default = "us-south"
}

variable "ibmcloud_api_key" {
  type      = string
  sensitive = true
}


variable "existing_key_name" {
  description = "Name of the ssh key to be used"
  type        = string
  default     = "murphy-clone-key"
}

variable "existing_network_id" {
  description = "current subnet ID"
  type        = string
  default     = "ca78b0d5-f77f-4e8c-9f2c-545ca20ff073"
}



variable "pvs_workspace_name" {
  description = "Name of the PowerVS workspace"
  type = string
  default = "murphy"
}


variable "pvs_ibmi_image_id" {
  description = "The image ID for the empty IBMi Image we want to deploy"
  type = string
  default = "5ccf25e5-e543-4fe7-bbc4-cf0fbb2be420"
}

variable "pvs_aix_image_name" {
  description = "The name of the image"
  type = string
  default = "7200-05-10"
}

variable "pvs_instance_cores" {
  description = "The number of cores for the instance"
  type = string
  default = ".25"
}

variable "pvs_instance_memory" {
  description = "The amount of memory (GB) for the instance"
  type = string
  default = "2"
}

variable "pvs_instance_name" {
  description = "The name of the lpar instance"
  type = string
  default = "empty lpar"
}
