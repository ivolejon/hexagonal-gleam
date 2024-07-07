import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import mist
import repositories/cache
import services/router
import wisp

pub fn main() {
  let fallback_port: Int = 3000
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(fallback_port)

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(ctx) = cache.new()

  let assert Ok(_) =
    wisp.mist_handler(router.handle_request(ctx), secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  ["Started listening on localhost:", int.to_string(port), " ✨"]
  |> string.concat
  |> io.println

  process.sleep_forever()
}
