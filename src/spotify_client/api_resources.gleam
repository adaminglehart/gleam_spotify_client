import gleam/dynamic/decode
import gleam/json
import gleam/option
import spotify_client/resource
import spotify_client/types.{
  type ID, APIResource, AddedBy, Album, Artist, Cursors, DateString, Followers,
  ID, Me, PlayHistoryObject, Playlist, PlaylistTrack, RecentlyPlayed,
  SimplifiedArtist, SimplifiedUser, Track,
}

pub fn track() {
  APIResource(slug: "tracks", decoder: track_decoder())
}

pub fn artist() {
  APIResource(slug: "artists", decoder: artist_decoder())
}

pub fn album() {
  APIResource(slug: "albums", decoder: album_decoder())
}

fn playlist_track() {
  APIResource(slug: "tracks", decoder: playlist_track_decoder())
}

pub fn playlist() {
  APIResource(slug: "playlists", decoder: playlist_decoder())
}

pub fn me() {
  APIResource(slug: "me", decoder: me_decoder())
}

fn followers_decoder() {
  use total <- decode.field("total", decode.int)

  decode.success(Followers(total:))
}

pub fn me_decoder() {
  use id <- decode.field("id", id_decoder())
  use email <- decode.field("email", decode.string)

  decode.success(Me(id:, email:, playlists: resource.has_many(playlist())))
}

pub fn simplified_user_decoder() {
  use id <- decode.field("id", id_decoder())
  use display_name <- decode.optional_field(
    "display_name",
    option.None,
    decode.optional(decode.string),
  )

  decode.success(SimplifiedUser(id:, display_name:))
}

pub fn added_by_decoder() {
  use id <- decode.field("id", id_decoder())

  decode.success(AddedBy(id:))
}

pub fn playlist_track_decoder() {
  use track <- decode.field("track", track_decoder())
  use added_at <- decode.field("added_at", datestring_decoder())
  use added_by <- decode.field("added_by", added_by_decoder())

  decode.success(PlaylistTrack(track:, added_at:, added_by:))
}

fn datestring_decoder() {
  decode.string |> decode.map(DateString)
}

pub fn playlist_decoder() {
  use id <- decode.field("id", id_decoder())
  use name <- decode.field("name", decode.string)
  use collaborative <- decode.field("collaborative", decode.bool)
  use public <- decode.field("public", decode.optional(decode.bool))
  use snapshot_id <- decode.field("snapshot_id", decode.string)

  use description <- decode.optional_field(
    "description",
    option.None,
    decode.optional(decode.string),
  )
  use followers <- decode.field("followers", followers_decoder())
  use owner <- decode.field("owner", simplified_user_decoder())

  decode.success(Playlist(
    id:,
    name:,
    collaborative:,
    public:,
    snapshot_id:,
    description:,
    followers:,
    owner:,
    tracks: resource.has_many(playlist_track()),
  ))
}

pub fn recently_played_decoder() {
  use items <- decode.field("items", decode.list(play_history_decoder()))
  use limit <- decode.field("limit", decode.int)
  use total <- decode.optional_field("total", -1, decode.int)
  use cursors <- decode.field("cursors", cursor_decoder())

  decode.success(RecentlyPlayed(items:, limit:, total:, cursors:))
}

pub fn play_history_decoder() {
  use track <- decode.field("track", track_decoder())
  use played_at <- decode.field("played_at", decode.string)

  decode.success(PlayHistoryObject(track:, played_at:))
}

pub fn artist_decoder() {
  use id <- decode.field("id", id_decoder())
  use name <- decode.field("name", decode.string)
  use genres <- decode.field("genres", decode.list(decode.string))
  use popularity <- decode.field("popularity", decode.int)

  decode.success(Artist(
    id:,
    name:,
    genres:,
    popularity:,
    albums: resource.has_many(album()),
  ))
}

pub fn simplified_artist_decoder() {
  use id <- decode.field("id", id_decoder())
  use name <- decode.field("name", decode.string)

  decode.success(SimplifiedArtist(
    id:,
    name:,
    albums: resource.has_many(album()),
  ))
}

pub fn track_decoder() {
  use id <- decode.field("id", id_decoder())
  use name <- decode.field("name", decode.string)
  use artists <- decode.field(
    "artists",
    decode.list(simplified_artist_decoder()),
  )
  use album <- decode.field("album", album_decoder())
  use duration_ms <- decode.field("duration_ms", decode.int)
  use popularity <- decode.field("popularity", decode.int)

  decode.success(Track(id:, name:, artists:, album:, duration_ms:, popularity:))
}

pub fn album_decoder() {
  use id <- decode.field("id", id_decoder())
  use name <- decode.field("name", decode.string)
  use artists <- decode.field(
    "artists",
    decode.list(simplified_artist_decoder()),
  )

  decode.success(Album(id:, name:, artists:, tracks: resource.has_many(track())))
}

pub fn id_decoder() -> decode.Decoder(ID(resource_type)) {
  decode.string |> decode.map(ID)
}

fn cursor_decoder() {
  use after <- decode.field("after", decode.string)
  use before <- decode.field("before", decode.string)

  decode.success(Cursors(after:, before:))
}

pub fn id_to_json(id: ID(resource_type)) {
  json.string(id.id)
}
