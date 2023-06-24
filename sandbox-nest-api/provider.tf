provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      "Project" : "sandbox-nest"
    }
  }
}
