import spotify_client/api_resources
import spotify_client/client
import spotify_client/resource
import spotify_client/types.{type Me, ID}

pub fn me(client: client.AuthenticatedClient) {
  resource.build_get(api_resources.me())(client, ID(""))
}

pub fn playlists(client: client.AuthenticatedClient, me: Me) {
  resource.list(api_resources.me(), me.playlists)(client, ID(""))
}
