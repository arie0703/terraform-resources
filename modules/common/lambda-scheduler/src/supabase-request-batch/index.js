import { createClient } from "@supabase/supabase-js";
import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";

const getSecretString = async () => {
  const client = new SecretsManagerClient();
  const response = await client.send(
    new GetSecretValueCommand({
      SecretId: process.env.SECRET_NAME,
    }),
  );

  if (response.SecretString) {
    return JSON.parse(response.SecretString);
  }
  return null
}

export async function handler(event, context) {
  const secrets = await getSecretString();

  const supabaseUrl = secrets.SUPABASE_URL;
  const supabaseKey = secrets.SUPABASE_KEY;
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
