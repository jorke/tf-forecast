
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias = "sydney"
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "useast"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

variable "aws_region" {
  default = "ap-southeast-2" 
}

variable "tags" {
    default = {}
}

variable "name" {
  default = "forecast"
}

resource "random_pet" "this" {
  keepers = {
    name_ext = var.name
  }
}


resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-${random_pet.this.id}"
  tags = var.tags
  force_destroy = true
}



resource "aws_cloudformation_stack" "this" {
  name = "${var.name}-${random_pet.this.id}"

  parameters = {
    DataSetGroup = "mygroup"
  }

  template_body = file("${path.module}/forecast.yaml")
  on_failure = "DELETE"
}
  


