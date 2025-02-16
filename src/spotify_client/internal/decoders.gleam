import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/json
import gleam/result
import gleam/time/timestamp

pub fn timestamp_decoder() -> decode.Decoder(timestamp.Timestamp) {
  decode.new_primitive_decoder("Timestamp", fn(data) {
    case dynamic.string(data) {
      Ok(string) -> {
        case timestamp.parse_rfc3339(string) {
          Ok(timestamp) -> Ok(timestamp)
          Error(_) -> Error(timestamp.system_time())
        }
      }
      Error(_) -> Error(timestamp.system_time())
    }
  })
}

pub fn timestamp_to_json(timestamp: timestamp.Timestamp) {
  timestamp.to_unix_seconds(timestamp) |> float.to_string |> json.string
}
