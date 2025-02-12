import gleam/json

pub type SpotifyError {
  JSONError(json.DecodeError)
  APIError(status: Int)
}
