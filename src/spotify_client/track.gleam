import gleam/dynamic/decode
import spotify_client/album
import spotify_client/artist

pub type Track {
  Track(
    id: String,
    name: String,
    artists: List(artist.SimplifiedArtist),
    album: album.Album,
    duration_ms: Int,
    popularity: Int,
  )
}

pub fn decoder() -> decode.Decoder(Track) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use artists <- decode.field("artists", decode.list(artist.decoder()))
  use album <- decode.field("album", album.decoder())
  use duration_ms <- decode.field("duration_ms", decode.int)
  use popularity <- decode.field("popularity", decode.int)

  decode.success(Track(id:, name:, artists:, album:, duration_ms:, popularity:))
}
