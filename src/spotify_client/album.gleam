import gleam/json
import spotify_client/api_resources
import spotify_client/client
import spotify_client/resource
import spotify_client/types.{type Album, type ID}

pub fn to_json(album: Album) {
  json.object([
    #("id", api_resources.id_to_json(album.id)),
    #("name", json.string(album.name)),
  ])
}

pub fn get(client: client.AuthenticatedClient, id: ID(Album)) {
  resource.build_get(api_resources.album())(client, id)
}

pub fn tracks(client: client.AuthenticatedClient, album: Album) {
  resource.list(api_resources.album(), album.tracks)(client, album.id)
}
