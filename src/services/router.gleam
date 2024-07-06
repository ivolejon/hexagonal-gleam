import gleam/bytes_builder.{type BytesBuilder}
import gleam/http.{Get, Post, Put}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/result
import models/employee.{type Employee}
import repositories/cache.{type Cache}
import serializers/employee_serializer.{encode_employee}

pub type HttpResponder {
  HttpResponder(execute_request: fn() -> Response(BytesBuilder))
}

type BuilderObject(t) {
  BuilderObject(request: Request(t), str: String, response_code: Int)
}

fn response_builder(payload: BuilderObject(t)) -> fn() -> Response(BytesBuilder) {
  fn() -> Response(BytesBuilder) {
    let body: BytesBuilder =
      payload.str
      |> bytes_builder.from_string

    let content_type =
      payload.request
      |> request.get_header("content-type")
      |> result.unwrap("text/plain")

    response.new(payload.response_code)
    |> response.prepend_header("made-by", "Ivo")
    |> response.prepend_header("content-type", content_type)
    |> response.set_body(body)
  }
}

fn ivo(ctx: Cache) {
  let e: Employee = employee.new("Ivo Lejon", "1979")
  cache.save(ctx, e)
  // let assert Ok(res) = employee_repository.read(actor, e.id)
  let assert Ok(res) = cache.read_collection(ctx)
  io.debug(res)
}

pub fn service(ctx: Cache) {
  fn(request: Request(t)) -> Response(BytesBuilder) {
    ivo(ctx)
    let path = request.path_segments(request)
    let handler = case request.method, path {
      Get, ["employee"] ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(
            request,
            "employee",
            200,
          )),
        )
      Get, ["echo"] ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(request, "id", 200)),
        )
      Get, ["echo", id] ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(request, id, 200)),
        )
      Get, ["hello"] ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(request, "leo", 200)),
        )
      Get, [] ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(
            request,
            "Not found",
            404,
          )),
        )
      _, _ ->
        HttpResponder(
          execute_request: response_builder(BuilderObject(request, "error", 500)),
        )
    }
    handler.execute_request()
  }
}
