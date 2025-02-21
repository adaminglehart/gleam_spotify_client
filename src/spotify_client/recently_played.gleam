import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import spotify_client/api_resources
import spotify_client/client
import spotify_client/internal/requests
import spotify_client/track
import spotify_client/types.{
  type Cursors, type PlayHistoryObject, type RecentlyPlayed,
}

fn play_history_to_json(play_history: PlayHistoryObject) {
  json.object([
    #("track", track.to_json(play_history.track)),
    #("played_at", json.string(play_history.played_at)),
  ])
}

fn cursor_to_json(cursors: Cursors) {
  json.object([
    #("after", json.string(cursors.after)),
    #("before", json.string(cursors.before)),
  ])
}

pub fn to_json(recently_played: RecentlyPlayed) {
  json.object([
    #("items", json.array(recently_played.items, play_history_to_json)),
    #("limit", json.int(recently_played.limit)),
    #("total", json.int(recently_played.total)),
    #("cursors", cursor_to_json(recently_played.cursors)),
  ])
}

pub fn recently_played(client: client.AuthenticatedClient) {
  recently_played_paginated(client, option.None)
}

type CursorParams {
  After(after: String)
  Before(before: String)
}

fn recently_played_paginated(
  client: client.AuthenticatedClient,
  cursor: option.Option(CursorParams),
) {
  let params =
    case cursor {
      option.Some(cursor) -> {
        case cursor {
          After(after) -> {
            [#("after", after)]
          }
          Before(before) -> {
            [#("before", before)]
          }
        }
      }
      option.None -> []
    }
    |> list.prepend(#("limit", "50"))

  requests.get(client, "/me/player/recently-played", option.Some(params))
  |> requests.send_request(api_resources.recently_played_decoder())
}
