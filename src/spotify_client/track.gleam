import gleam/json
import spotify_client/album
import spotify_client/api_resources
import spotify_client/artist
import spotify_client/client
import spotify_client/resource
import spotify_client/types.{type ID, type Track}

pub fn to_json(track: Track) {
  json.object([
    #("id", api_resources.id_to_json(track.id)),
    #("name", json.string(track.name)),
    #("artists", json.array(track.artists, artist.to_json)),
    #("album", album.to_json(track.album)),
    #("duration_ms", json.int(track.duration_ms)),
    #("popularity", json.int(track.popularity)),
  ])
}

pub fn get(client: client.AuthenticatedClient, id: ID(Track)) {
  resource.build_get(api_resources.track())(client, id)
}
