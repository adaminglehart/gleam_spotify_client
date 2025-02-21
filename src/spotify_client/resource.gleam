import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import spotify_client/client
import spotify_client/internal/error
import spotify_client/internal/requests
import spotify_client/types.{type APIResource, type HasMany, type ID, HasMany}

pub fn has_many(resource: APIResource(a)) {
  HasMany(resource:)
}

pub fn build_get(resource: APIResource(a)) {
  fn(client: client.AuthenticatedClient, id: ID(a)) {
    requests.get(client, "/" <> resource.slug <> "/" <> id.id, option.None)
    |> requests.send_request(resource.decoder)
  }
}

fn has_many_path(
  resource: APIResource(a),
  relation: HasMany(b),
  parent_resource_id: ID(a),
) {
  resource.slug <> "/" <> parent_resource_id.id <> "/" <> relation.resource.slug
}

fn get_paginated_has_many_result(resource: APIResource(a), relation: HasMany(b)) {
  fn(
    client: client.AuthenticatedClient,
    parent_resource_id: ID(a),
    cursor: option.Option(Cursor),
  ) {
    let cursor_params = cursor |> option.map(params_for_cursor)
    let slug = has_many_path(resource, relation, parent_resource_id)

    requests.get(client, slug, cursor_params)
    |> requests.send_request(paginated_result_decoder(relation.resource, slug))
  }
}

pub fn list(resource: APIResource(a), relation: HasMany(b)) {
  fn(client: client.AuthenticatedClient, parent_resource_id: ID(a)) -> Result(
    PaginatedResult(b),
    error.SpotifyError,
  ) {
    case
      get_paginated_has_many_result(resource, relation)(
        client,
        parent_resource_id,
        option.Some(Start(limit: default_limit)),
      )
    {
      Ok(result) -> list_acc(client, result)
      Error(err) -> Error(err)
    }
  }
}

pub fn next() {
  fn(client: client.AuthenticatedClient, result: PaginatedResult(b)) {
    let cursor_params = result.next_cursor |> option.map(params_for_cursor)

    requests.get(client, result.slug, cursor_params)
    |> requests.send_request(paginated_result_decoder(
      result.resource,
      result.slug,
    ))
  }
}

pub type Cursor {
  Cursor(limit: Int, offset: Int)
  Start(limit: Int)
}

pub type PaginatedResult(a) {
  PaginatedResult(
    items: List(a),
    next_cursor: option.Option(Cursor),
    resource: APIResource(a),
    slug: String,
  )
}

const default_limit = 50

fn params_for_cursor(cursor: Cursor) {
  case cursor {
    Start(limit) -> {
      [#("limit", int.to_string(limit))]
    }
    Cursor(limit, offset) -> {
      [#("limit", int.to_string(limit)), #("offset", int.to_string(offset))]
    }
  }
}

fn list_acc(
  client: client.AuthenticatedClient,
  result: PaginatedResult(b),
) -> Result(PaginatedResult(b), error.SpotifyError) {
  case result.next_cursor {
    option.Some(_) -> {
      next()(client, result)
      |> result.map(fn(next_result) {
        PaginatedResult(
          items: list.append(result.items, next_result.items),
          resource: next_result.resource,
          next_cursor: next_result.next_cursor,
          slug: next_result.slug,
        )
      })
      |> result.map(list_acc(client, _))
      |> result.flatten
    }
    option.None -> {
      Ok(result)
    }
  }
}

fn paginated_result_decoder(
  resource: APIResource(a),
  slug: String,
) -> decode.Decoder(PaginatedResult(a)) {
  use items <- decode.field("items", decode.list(resource.decoder))
  use total <- decode.field("total", decode.int)
  use limit <- decode.field("limit", decode.int)
  use offset <- decode.field("offset", decode.int)

  let next_cursor = case total > offset {
    True -> option.Some(Cursor(limit:, offset: offset + limit))
    False -> option.None
  }

  decode.success(PaginatedResult(items:, next_cursor:, resource:, slug:))
}
