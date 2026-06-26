variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "The name of the project — used as a prefix for all resources"
  type        = string
  default     = "calculator-app"
}

variable "ami_id" {
  description = "Amazon Linux / Ubuntu AMI ID for EC2 instances"
  type        = string
  default     = "ami-0521cb2d60cfbb1a6"
}

variable "inst_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "SSH public key material (contents of your id_rsa.pub)"
  type        = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnmVkH3kiIUriUW6D6Gzt4KeIxLxxqxtl2YSlTcS4FiX1kqjnH5nh8UeFXvfzqEW5EaDgBDNPOqZW9cqJ3yQFodgHV8rYNg0a6d+6glDvPRic986yaQKiNp9MG6Mu96lsOP54nf9THG7bvynpMKA4xXQsQBDkYFHLDdvaMGS/yHRVfX0bLFYG54uOlvgAWBdndoS82vAhiZlddORvIYnbdfEDEbLwbp6CEiDXBQy2/hry9oYEoYiO3NMxV/8WCCVGevgtlbrCUISYPZOntrq9og0GDQccU8TFTiMVO+ibPMaEepSpXmWsmPPIEBSEdHlWcMMhgBlyzQF4EpgLh/jnUjaXPhd9/Li/pc/1H8HyVklRvekIIUVZfJr5sQCgm1AkOB06oMxy6nwSx24xFAxpVDAjYXjlsLrDlxI2UbZikwl0KyThw/vWsFhDiHzVExl5dXA/1YR1PcnspOArqDIO/ppzjfn/40GOsQf3qvam/5iRR0ni9PokUnRr7zScbQfl2FVwj87nBNswTvs5fEpe2n73fwNgKEu0JhKyQOp2DimRQ4nkLDmEzZ2I8tkxENHw0g5HVr4Ore/nes54BNy/RPuJDCJitI+IpoLt7KLqgQ/1+2qQfdQpL1Gk5kq6yR/jNE05wkOX9K4BMhiMB4bHc/gG9Mw6FY4aPR9OlPW0Gcw== Dell@DESKTOP-K8GNMIF"
  sensitive   = true
}

variable "admin_cidr" {
  description = "Your workstation IP in CIDR for bastion SSH access, e.g. 203.0.113.5/32"
  type        = string
  default     = "0.0.0.0/0"   # restrict this to your real IP in practice
}

variable "app_port" {
  description = "Port your Java backend application listens on"
  type        = number
  default     = 8080
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "calculatordb"
}

variable "user_name" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "RDS master password — use a secrets manager in production"
  type        = string
  sensitive   = true          # ENHANCEMENT: marks value as sensitive in plan output
  default     = "ChangeMe123!"
}

variable "identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "calculator-db"
}
