provider "ibm" {
  region = "us-south"
  zone   = "dal10"
  ibmcloud_api_key = var.ibmcloud_api_key
}


terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "= 1.38.2"
    }
  }
}

