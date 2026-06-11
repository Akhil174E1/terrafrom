module "demo"{
    source = "../S3_module"
    name   = var.bucket_name
    acl = var.acl
    
}