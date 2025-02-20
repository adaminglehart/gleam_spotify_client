import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import spotify_client/client
import spotify_client/internal/error
import spotify_client/internal/requests

pub type ID(resource) {
  ID(id: String)
}

pub fn id_decoder() -> decode.Decoder(ID(resource_type)) {
  decode.string |> decode.map(ID)
}

pub fn to_json(id: ID(resource_type)) {
  json.string(id.id)
}

pub opaque type APIResource(a) {
  APIResource(
    slug: String,
    decoder: decode.Decoder(a),
    get: fn(client.AuthenticatedClient, String) -> Result(a, error.SpotifyError),
  )
}

pub fn define_resource(slug: String, decoder: decode.Decoder(a)) {
  let get = fn(client: client.AuthenticatedClient, id: String) {
    requests.get(client, "/" <> slug <> "/" <> id, option.None)
    |> requests.send_request(decoder)
  }

  APIResource(slug:, decoder:, get:)
}

pub type RelationResource(a) {
  HasMany(
    list: fn(client.AuthenticatedClient) -> Result(List(a), error.SpotifyError),
  )
}

pub fn has_many(
  parent_resource: APIResource(a),
  parent_resource_id: String,
  resource: APIResource(b),
) {
  let list = fn(client: client.AuthenticatedClient) {
    list(client, parent_resource, parent_resource_id, resource)
  }

  HasMany(list:)
}

type Cursor {
  Cursor(limit: Int, offset: Int)
  Start(limit: Int)
}

type PaginatedResult(a) {
  PaginatedResult(items: List(a), next_cursor: option.Option(Cursor))
}

const default_limit = 50

fn list(
  client: client.AuthenticatedClient,
  parent_resource: APIResource(a),
  parent_resource_id: String,
  resource: APIResource(b),
) {
  list_acc(
    client,
    option.Some(Start(default_limit)),
    parent_resource,
    parent_resource_id,
    resource,
  )
  |> result.map(fn(result) { result |> list.flat_map(fn(r) { r.items }) })
}

fn list_acc(
  client: client.AuthenticatedClient,
  cursor: option.Option(Cursor),
  parent_resource: APIResource(a),
  parent_resource_id: String,
  resource: APIResource(b),
) -> Result(List(PaginatedResult(b)), error.SpotifyError) {
  case cursor {
    option.Some(cursor) -> {
      let params = case cursor {
        Start(limit) -> {
          [#("limit", int.to_string(limit))]
        }
        Cursor(limit, offset) -> {
          [#("limit", int.to_string(limit)), #("offset", int.to_string(offset))]
        }
      }

      requests.get(
        client,
        "/"
          <> parent_resource.slug
          <> "/"
          <> parent_resource_id
          <> "/"
          <> resource.slug,
        option.Some(params),
      )
      |> requests.send_request(items_decoder(resource.decoder))
      |> result.map(fn(result) {
        list_acc(
          client,
          result.next_cursor,
          parent_resource,
          parent_resource_id,
          resource,
        )
        |> result.map(fn(next_result) { [result, ..next_result] })
      })
      |> result.flatten
    }
    option.None -> {
      Ok([])
    }
  }
}

fn items_decoder(
  decoder: decode.Decoder(a),
) -> decode.Decoder(PaginatedResult(a)) {
  use items <- decode.field("items", decode.list(decoder))
  use total <- decode.field("total", decode.int)
  use limit <- decode.field("limit", decode.int)
  use offset <- decode.field("offset", decode.int)

  let next_cursor = case total > offset {
    True -> option.Some(Cursor(limit, offset + limit))
    False -> option.None
  }

  decode.success(PaginatedResult(items:, next_cursor:))
}
