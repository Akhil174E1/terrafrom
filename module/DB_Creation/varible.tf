variable "bucket_name" {
    description = "Name of the S3 bucket"
    type        = string
    default     = "akhil-001"
  
}

variable "acl" {
    description = "Access control list for the S3 bucket"
    type        = string
    default     = "private"
  
}