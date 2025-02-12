import gleam/bit_array
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option
import spotify_client/client
import spotify_client/internal/error.{type SpotifyError, JSONError}

const base_url = "api.spotify.com/v1"

pub fn make_request(
  client: client.AuthenticatedClient,
  path: String,
  method: http.Method,
  body: option.Option(String),
) -> Request(String) {
  request.new()
  |> request.set_scheme(http.Https)
  |> request.set_method(method)
  |> request.set_host(base_url)
  |> request.set_path(path)
  |> set_header("content-type", "application/json")
  |> set_header("Accept", "application/json")
  |> set_header("Authorization", "Bearer " <> client.auth.access_token)
  |> fn(request) -> Request(String) {
    // we only want to set the body if it's not a GET request
    case method, body {
      http.Post, option.Some(body_content) ->
        request.set_body(request, body_content)
      _, _ -> request
    }
  }
}

pub fn set_header(
  req: Request(String),
  key: String,
  value: String,
) -> Request(String) {
  Request(..req, headers: [#(key, value), ..req.headers])
}

pub fn client_id_auth_header(client: client.SpotifyClient(_)) -> String {
  let auth_string = client.client_id <> ":" <> client.client_secret

  let encoded_auth_string =
    auth_string
    |> bit_array.from_string
    |> bit_array.base64_encode(False)

  "Basic " <> encoded_auth_string
}

pub fn decoder(
  data: String,
  decoder: fn() -> Decoder(a),
) -> Result(a, SpotifyError) {
  case json.parse(from: data, using: decoder()) {
    Ok(decoded) -> Ok(decoded)
    Error(err) -> Error(JSONError(err))
  }
}

pub fn decode(decoder: Decoder(a)) {
  fn(res: response.Response(String)) {
    let response.Response(body: body, status: status, ..) = res

    case status {
      status if status >= 200 && status < 300 -> {
        case json.parse(from: body, using: decoder) {
          Ok(decoded) -> Ok(decoded)
          Error(err) -> Error(JSONError(err))
        }
      }
      status -> {
        Error(error.APIError(status))
      }
    }
  }
}
