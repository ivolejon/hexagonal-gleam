import gleam/erlang/os
import gleam/erlang/process
import gleam/http/elli
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import repositories/cache.{type Cache}
import services/router

pub fn main() {
  let fallback_port: Int = 3000
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(fallback_port)

  let assert Ok(ctx) = cache.new()

  let _ = elli.start(router.service(ctx), on_port: port)
  ["Started listening on localhost:", int.to_string(port), " ✨"]
  |> string.concat
  |> io.println
  process.sleep_forever()
}
