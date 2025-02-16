import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import spotify_client/internal/requests

pub type SimplifiedArtist {
  SimplifiedArtist(id: String, name: String)
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)

  decode.success(SimplifiedArtist(id:, name:))
}

pub fn decode(res: response.Response(String)) {
  requests.decode_builder(decoder())(res)
}

pub fn to_json(artist: SimplifiedArtist) {
  json.object([
    #("id", json.string(artist.id)),
    #("name", json.string(artist.name)),
  ])
}

pub fn get_artist(id: String) {
  todo
}
