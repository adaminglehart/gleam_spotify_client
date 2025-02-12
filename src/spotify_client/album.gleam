import gleam/dynamic/decode

pub type Album {
  Album(id: String, name: String)
}

pub fn decoder() -> decode.Decoder(Album) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)

  decode.success(Album(id:, name:))
}
