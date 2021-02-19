variable "domain_name" {
  type        = string
  description = "The domain name for the website e.g. cloudbunny.cloud"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket usually same as domain name e.g cloudbunny.cloud"
}

variable "common_tags" {
  description = "Tag applies to all resources e.g cloudbunny"
}