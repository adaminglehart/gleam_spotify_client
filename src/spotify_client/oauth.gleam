import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/io
import gleam/option
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import gleam/uri
import spotify_client/client.{
  type AuthenticatedClient, type BaseClient, type SpotifyClient,
}
import spotify_client/internal/requests

pub fn exchange_code(
  client: BaseClient,
  code: String,
) -> request.Request(String) {
  let body =
    uri.query_to_string([
      #("code", code),
      #("redirect_uri", client.redirect_uri),
      #("grant_type", "authorization_code"),
    ])

  base_token_request(client)
  |> request.set_body(body)
}

fn base_token_request(client: SpotifyClient(_)) {
  request.new()
  |> request.set_host("accounts.spotify.com")
  |> request.set_scheme(http.Https)
  |> request.set_path("/api/token")
  |> request.set_method(http.Post)
  |> requests.set_header("content-type", "application/x-www-form-urlencoded")
  |> requests.set_header(
    "Authorization",
    requests.client_id_auth_header(client),
  )
}

pub fn refresh_access_token(client: AuthenticatedClient) {
  let body =
    uri.query_to_string([
      #("grant_type", "refresh_token"),
      #("refresh_token", client.auth.refresh_token),
      #("client_id", client.client_id),
    ])

  base_token_request(client) |> request.set_body(body)
}

pub type TokenResponse {
  TokenResponse(access_token: String, refresh_token: String, expires_at: String)
}

pub type RefreshTokenResponse {
  RefreshTokenResponse(
    access_token: String,
    refresh_token: option.Option(String),
    expires_at: String,
  )
}

pub fn decoder() -> decode.Decoder(TokenResponse) {
  use access_token <- decode.field("access_token", decode.string)
  use refresh_token <- decode.field("refresh_token", decode.string)
  use expires_in <- decode.field("expires_in", decode.int)

  let expires_at =
    timestamp.add(timestamp.system_time(), duration.seconds(expires_in))
    |> timestamp.to_rfc3339(calendar.utc_offset)

  decode.success(TokenResponse(access_token:, refresh_token:, expires_at:))
}

pub fn refresh_response_decoder() -> decode.Decoder(RefreshTokenResponse) {
  use access_token <- decode.field("access_token", decode.string)

  use refresh_token <- decode.optional_field(
    "refresh_token",
    option.None,
    decode.optional(decode.string),
  )
  use expires_in <- decode.field("expires_in", decode.int)

  let expires_at =
    timestamp.add(timestamp.system_time(), duration.seconds(expires_in))
    |> timestamp.to_rfc3339(calendar.utc_offset)

  decode.success(RefreshTokenResponse(
    access_token:,
    refresh_token:,
    expires_at:,
  ))
}

pub fn decode(res: response.Response(String)) {
  io.print(res.body)
  requests.decode_builder(decoder())(res)
}

pub fn decode_refresh_response(res: response.Response(String)) {
  io.print(res.body)
  requests.decode_builder(refresh_response_decoder())(res)
}

pub fn authenticate_from_token_response(
  client: BaseClient,
  response: TokenResponse,
) {
  let assert Ok(expires_at) = timestamp.parse_rfc3339(response.expires_at)

  client.authenticate(
    client,
    response.access_token,
    response.refresh_token,
    expires_at,
  )
}
