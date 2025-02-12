import gleam/dynamic/decode

pub type SimplifiedArtist {
  SimplifiedArtist(id: String, name: String)
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)

  decode.success(SimplifiedArtist(id:, name:))
}
