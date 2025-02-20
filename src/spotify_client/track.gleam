import gleam/dynamic/decode
import gleam/json
import gleam/option
import spotify_client/album
import spotify_client/artist
import spotify_client/client
import spotify_client/internal/error
import spotify_client/internal/requests
import spotify_client/resource.{type ID, ID}

pub type Track {
  Track(
    id: ID(Track),
    name: String,
    artists: List(artist.SimplifiedArtist),
    album: album.Album,
    duration_ms: Int,
    popularity: Int,
  )
}

pub fn decoder() -> decode.Decoder(Track) {
  use id <- decode.field("id", resource.id_decoder())
  use name <- decode.field("name", decode.string)
  use artists <- decode.field(
    "artists",
    decode.list(artist.simplified_artist_decoder()),
  )
  use album <- decode.field("album", album.decoder())
  use duration_ms <- decode.field("duration_ms", decode.int)
  use popularity <- decode.field("popularity", decode.int)

  decode.success(Track(id:, name:, artists:, album:, duration_ms:, popularity:))
}

pub fn to_json(track: Track) {
  json.object([
    #("id", resource.to_json(track.id)),
    #("name", json.string(track.name)),
    #("artists", json.array(track.artists, artist.to_json)),
    #("album", album.to_json(track.album)),
    #("duration_ms", json.int(track.duration_ms)),
    #("popularity", json.int(track.popularity)),
  ])
}

pub fn get(client: client.AuthenticatedClient, id: String) {
  requests.get(client, "/tracks/" <> id, option.None)
  |> requests.send_request(decoder())
}
