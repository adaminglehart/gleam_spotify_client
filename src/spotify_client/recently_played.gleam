import gleam/dynamic/decode
import gleam/http
import gleam/http/response
import gleam/json
import gleam/option
import gleam/time/timestamp
import spotify_client/client
import spotify_client/internal/decoders
import spotify_client/internal/requests
import spotify_client/track

pub type PlayHistoryObject {
  PlayHistoryObject(track: track.Track, played_at: String)
}

fn play_history_decoder() {
  use track <- decode.field("track", track.decoder())
  use played_at <- decode.field("played_at", decode.string)

  decode.success(PlayHistoryObject(track:, played_at:))
}

fn play_history_to_json(play_history: PlayHistoryObject) {
  json.object([
    #("track", track.to_json(play_history.track)),
    #("played_at", json.string(play_history.played_at)),
  ])
}

pub type Cursors {
  Cursors(after: String, before: String)
}

fn cursor_decoder() {
  use after <- decode.field("after", decode.string)
  use before <- decode.field("before", decode.string)

  decode.success(Cursors(after:, before:))
}

fn cursor_to_json(cursors: Cursors) {
  json.object([
    #("after", json.string(cursors.after)),
    #("before", json.string(cursors.before)),
  ])
}

pub type RecentlyPlayed {
  RecentlyPlayed(
    items: List(PlayHistoryObject),
    limit: Int,
    total: Int,
    cursors: Cursors,
  )
}

fn decoder() -> decode.Decoder(RecentlyPlayed) {
  use items <- decode.field("items", decode.list(play_history_decoder()))
  use limit <- decode.field("limit", decode.int)
  use total <- decode.optional_field("total", -1, decode.int)
  use cursors <- decode.field("cursors", cursor_decoder())

  decode.success(RecentlyPlayed(items:, limit:, total:, cursors:))
}

pub fn decode(res: response.Response(String)) {
  requests.decode_builder(decoder())(res)
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
  requests.make_request(
    client,
    "/me/player/recently-played",
    http.Get,
    option.None,
  )
}
