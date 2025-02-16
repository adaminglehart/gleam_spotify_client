import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type ID(resource) {
  ID(id: String)
}

pub fn id_decoder() -> decode.Decoder(ID(resource_type)) {
  decode.string |> decode.map(ID)
}

pub fn to_json(id: ID(resource_type)) {
  json.string(id.id)
}
