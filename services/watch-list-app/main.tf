module "supabase" {
  source = "../../modules/supabase"

  supabase_token  = var.supabase_token
  organization_id = "glkladkbyccryxkcmxib"
  project_name    = "arie-dev"
  region          = "ap-northeast-1"
}
