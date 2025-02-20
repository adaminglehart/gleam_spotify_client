import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import gleam/option
import spotify_client/client
import spotify_client/internal/requests
import spotify_client/resource

pub type Album {
  Album(id: String, name: String)
}

pub fn decoder() -> decode.Decoder(Album) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)

  decode.success(Album(id:, name:))
}

pub fn to_json(album: Album) {
  json.object([
    #("id", json.string(album.id)),
    #("name", json.string(album.name)),
  ])
}

pub fn decode(res: response.Response(String)) {
  requests.decode_builder(decoder())(res)
}

pub fn get(client: client.AuthenticatedClient, id: String) {
  requests.get(client, "/albums/" <> id, option.None)
  |> requests.send_request(decoder())
}

pub fn api_resource() {
  resource.define_resource("albums", decoder())
}
