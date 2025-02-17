import gleam/dynamic/decode
import gleam/option
import spotify_client/client
import spotify_client/internal/requests

pub type MeResponse {
  MeResponse(id: String, email: String)
}

pub fn me(client: client.AuthenticatedClient) {
  requests.get(client, "/me", option.None) |> requests.send_request(decoder())
}

fn decoder() -> decode.Decoder(MeResponse) {
  use id <- decode.field("id", decode.string)
  use email <- decode.field("email", decode.string)

  decode.success(MeResponse(id, email))
}
