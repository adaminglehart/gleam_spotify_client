import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/uri
import spotify_client/client.{type BaseClient}
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
  |> request.set_body(body)
}

pub type TokenResponse {
  TokenResponse(access_token: String, refresh_token: String, expires_in: Int)
}

pub fn decoder() -> decode.Decoder(TokenResponse) {
  use access_token <- decode.field("access_token", decode.string)
  use refresh_token <- decode.field("refresh_token", decode.string)
  use expires_in <- decode.field("expires_in", decode.int)

  decode.success(TokenResponse(access_token:, refresh_token:, expires_in:))
}

pub fn decode(res: response.Response(String)) {
  requests.decode(decoder())(res)
}
