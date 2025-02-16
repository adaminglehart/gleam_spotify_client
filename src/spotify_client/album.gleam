import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import spotify_client/internal/requests

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
