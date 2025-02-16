import gleam/time/timestamp

pub type SpotifyClient(user_authentication) {
  SpotifyClient(
    client_id: String,
    client_secret: String,
    redirect_uri: String,
    auth: user_authentication,
  )
}

pub type BaseClient =
  SpotifyClient(Nil)

pub type UserAuthentication {
  UserAuthentication(
    access_token: String,
    refresh_token: String,
    expires_at: timestamp.Timestamp,
  )
}

pub type AuthenticatedClient =
  SpotifyClient(UserAuthentication)

pub fn authenticate(
  client: BaseClient,
  access_token: String,
  refresh_token: String,
  expires_at: timestamp.Timestamp,
) -> AuthenticatedClient {
  SpotifyClient(
    redirect_uri: client.redirect_uri,
    client_id: client.client_id,
    client_secret: client.client_secret,
    auth: UserAuthentication(access_token, refresh_token, expires_at),
  )
}
