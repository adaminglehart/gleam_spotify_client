import gleam/dynamic/decode
import gleam/json
import gleam/option
import spotify_client/album
import spotify_client/client
import spotify_client/internal/requests
import spotify_client/resource

pub type SimplifiedArtist {
  SimplifiedArtist(
    id: String,
    name: String,
    albums: resource.RelationResource(album.Album),
  )
}

pub type Artist {
  Artist(
    id: String,
    name: String,
    genres: List(String),
    popularity: Int,
    albums: resource.RelationResource(album.Album),
  )
}

pub fn simplified_artist_decoder() -> decode.Decoder(SimplifiedArtist) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)

  decode.success(SimplifiedArtist(
    id:,
    name:,
    albums: resource.has_many(api_resource(), id, album.api_resource()),
  ))
}

fn api_resource() -> resource.APIResource(Artist) {
  resource.define_resource("artists", artist_decoder())
}

fn artist_decoder() {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use genres <- decode.field("genres", decode.list(decode.string))
  use popularity <- decode.field("popularity", decode.int)

  decode.success(Artist(
    id:,
    name:,
    genres:,
    popularity:,
    albums: resource.has_many(api_resource(), id, album.api_resource()),
  ))
}

pub fn to_json(artist: SimplifiedArtist) {
  json.object([
    #("id", json.string(artist.id)),
    #("name", json.string(artist.name)),
  ])
}

pub fn get(client: client.AuthenticatedClient, id: String) {
  requests.get(client, "/artists/" <> id, option.None)
  |> requests.send_request(artist_decoder())
}
