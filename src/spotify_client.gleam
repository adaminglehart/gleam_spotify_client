import spotify_client/client

pub fn new(
  client_id: String,
  client_secret: String,
  redirect_uri: String,
) -> client.BaseClient {
  client.SpotifyClient(client_id, client_secret, redirect_uri, auth: Nil)
}
