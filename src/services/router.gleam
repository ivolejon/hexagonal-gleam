import gleam/http.{Get, Post, Put}
import gleam/string_builder
import models/employee
import repositories/cache.{type Cache}
import serializers/employee_serializer.{
  decode_new_employee, encode_employee_collection,
}
import services/employee_service
import wisp.{type Request, type Response}

pub fn handle_request(ctx: Cache) {
  fn(req: Request) -> Response {
    case req.method, wisp.path_segments(req) {
      Post, ["employee"] -> handle_post(req, ctx)
      Get, ["employee"] -> handle_get(req, ctx)
      Get, ["employee", id] -> handle_get_id(req, ctx, id)
      Put, ["employee", id] -> handle_put(req, ctx, id)
      _, _ -> wisp.not_found()
    }
  }
}

fn handle_put(req: Request, ctx: Cache, id: String) -> Response {
  use body <- wisp.require_string_body(req)
  case employee.from_json(body) {
    Ok(incoming_employee_update) -> {
      case cache.read(ctx, id) {
        Ok(existing_employee) -> {
          let assert Ok(updated_employee) =
            employee_service.update(existing_employee, incoming_employee_update)
          cache.save(ctx, updated_employee)

          employee.to_json(updated_employee)
          |> string_builder.from_string
          |> wisp.json_response(200)
        }
        Error(_) -> wisp.not_found()
      }
    }
    Error(_) -> wisp.bad_request()
  }
}

fn handle_post(req: Request, ctx: Cache) -> Response {
  use body <- wisp.require_string_body(req)
  case decode_new_employee(body) {
    Ok(new_employee) -> {
      case employee_service.new(new_employee.name, new_employee.birth) {
        Ok(employee) -> {
          cache.save(ctx, employee)
          let assert Ok(res) = cache.read(ctx, employee.id)
          employee.to_json(res)
          |> string_builder.from_string
          |> wisp.json_response(200)
        }
        Error(_) -> wisp.bad_request()
      }
    }
    Error(_) -> wisp.bad_request()
  }
}

fn handle_get(_, ctx: Cache) -> Response {
  let assert Ok(res) = cache.read_collection(ctx)
  encode_employee_collection(res)
  |> string_builder.from_string
  |> wisp.json_response(200)
}

fn handle_get_id(_, ctx: Cache, id: String) -> Response {
  case cache.read(ctx, id) {
    Ok(employee) -> {
      employee.to_json(employee)
      |> string_builder.from_string
      |> wisp.json_response(200)
    }
    Error(_) -> wisp.not_found()
  }
}
