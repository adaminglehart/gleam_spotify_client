import gleam/dynamic/decode
import gleam/option

pub type Cursors {
  Cursors(after: String, before: String)
}

pub type RecentlyPlayed {
  RecentlyPlayed(
    items: List(PlayHistoryObject),
    limit: Int,
    total: Int,
    cursors: Cursors,
  )
}

pub type PlayHistoryObject {
  PlayHistoryObject(track: Track, played_at: String)
}

pub type ID(resource) {
  ID(id: String)
}

pub type SimplifiedArtist {
  SimplifiedArtist(id: ID(Artist), name: String, albums: HasMany(Album))
}

pub type Followers(a) {
  Followers(total: Int)
}

pub type Playlist {
  Playlist(
    id: ID(Playlist),
    name: String,
    collaborative: Bool,
    public: option.Option(Bool),
    snapshot_id: String,
    description: option.Option(String),
    tracks: HasMany(PlaylistTrack),
    followers: Followers(Playlist),
    owner: SimplifiedUser,
  )
}

pub type User {
  User(id: ID(User))
}

pub type Me {
  Me(id: ID(User), email: String, playlists: HasMany(Playlist))
}

pub type SimplifiedUser {
  SimplifiedUser(id: ID(User), display_name: option.Option(String))
}

pub type AddedBy {
  AddedBy(id: ID(User))
}

pub type PlaylistTrack {
  PlaylistTrack(track: Track, added_at: DateString, added_by: AddedBy)
}

pub type Artist {
  Artist(
    id: ID(Artist),
    name: String,
    genres: List(String),
    popularity: Int,
    albums: HasMany(Album),
  )
}

pub type Album {
  Album(
    id: ID(Album),
    name: String,
    artists: List(SimplifiedArtist),
    tracks: HasMany(Track),
  )
}

pub type Track {
  Track(
    id: ID(Track),
    name: String,
    artists: List(SimplifiedArtist),
    album: Album,
    duration_ms: Int,
    popularity: Int,
  )
}

pub type HasMany(a) {
  HasMany(resource: APIResource(a))
}

pub type APIResource(a) {
  APIResource(slug: String, decoder: decode.Decoder(a))
}

pub type DateString {
  DateString(value: String)
}
