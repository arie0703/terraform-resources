terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "1.4.1"
    }
  }
}

provider "supabase" {
  access_token = var.supabase_token
}
