variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "web_ami" {
  description = "Name, virtualization-type, and owner of web app's AMI"

  type = object({
    name      = string
    virt_type = string
    owner     = string
  })

  default = {
    name      = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    virt_type = "hvm"
    owner     = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "Current environment"

  type = object({
    name           = string
    network_prefix = string
  })

  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_min_size" {
  description = "Auto-scaling group min size"
  default     = 3
}

variable "asg_max_size" {
  description = "Auto-scaling group max size"
  default     = 5
}
