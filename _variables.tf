variable "jenkins_version" {
  description = "Jenkins version you want to install"
  type        = any
}

variable "custom_cidr" {
  description = "Custom CIDR block. Enter a CIDR block from where you want to allow access to Jenkins."
  type        = string
  default     = "0.0.0.0/0"
}

variable "assign_public_ip" {
  description = "Assign public IP to Jenkins server if true, otherwise, do not assign."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet Ids where server will be launched"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3a.medium"
}

variable "project_name_prefix" {
  description = "A string value to describe prefix of all the resources"
  type        = string
  default     = "prod"
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "A string value for VPC ID"
  type        = string
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "A string value for Security Group ID"
  default     = []
}

variable "common_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {
    "Created By" = "Terraform"
    }
}

variable "delete_on_termination" {
  description = "Whether EBS volume will be deleted when instance gets deleted."
  type        = bool
  default     = true
}

variable "encrypted" {
  description = "Whether EBS volume will be encrypted."
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "Volume type for EC2 instance default latest type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size of the EC2 instance"
  type        = number
  default     = 100
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection."
  type        = bool
  default     = false
}

variable "source_dest_check" {
  description = "Source destination Check. Used for NAT or VPNs."
  type        = bool
  default     = true
}