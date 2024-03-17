terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.93.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
    ansible = {
      source = "ansible/ansible"
      version = "1.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}