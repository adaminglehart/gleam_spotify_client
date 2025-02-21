import gleam/json
import spotify_client/api_resources
import spotify_client/client
import spotify_client/resource
import spotify_client/types.{type Artist, type ID, type SimplifiedArtist}

pub fn to_json(artist: SimplifiedArtist) {
  json.object([
    #("id", api_resources.id_to_json(artist.id)),
    #("name", json.string(artist.name)),
  ])
}

pub fn get(client: client.AuthenticatedClient, id: ID(Artist)) {
  resource.build_get(api_resources.artist())(client, id)
}

pub fn albums(client: client.AuthenticatedClient, artist: SimplifiedArtist) {
  resource.list(api_resources.artist(), artist.albums)(client, artist.id)
}
