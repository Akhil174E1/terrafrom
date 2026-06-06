terraform {
    backend "s3" {
        bucket = "akhil-001"
        key    = "D:\repo900am\terrafrom\terraform.tfstate"
        file_lock=true
        region = "us-east-1"
    }
  
}