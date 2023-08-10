variable "project" {
  type = string
}

variable "credentials_file" {}

variable "google_dns_sa_file" {}

variable "region" {
  default = "europe-southwest1"
}

variable "numberOfNodes" {
  default = 2
}

variable "zone" {
  default = "europe-southwest1-a"
}

variable "lb-static-ip" {
  default = "traefik-lb-static-ip-tmp"
}

locals {
  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
