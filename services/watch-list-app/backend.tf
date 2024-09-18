terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "1.4.1"
    }
  }
  backend "s3" {
    bucket = "arie-terraform-states"
    region = "ap-northeast-1"
    key    = "watch-list-app/terraform.tfstate"
  }
}
