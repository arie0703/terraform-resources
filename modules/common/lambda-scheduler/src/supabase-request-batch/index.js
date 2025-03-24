import { createClient } from "@supabase/supabase-js";

export async function handler (event, context) {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_KEY;
  const supabase = createClient(supabaseUrl, supabaseKey);

  const { data, error } = await supabase
    .from("watchlist")
    .select("id")
    .limit(1);
  
  if (error) return error;

  const body = {
    message: "success",
    data: data,
  }

  return {
    statusCode: 200,
    body: body
  }
};
