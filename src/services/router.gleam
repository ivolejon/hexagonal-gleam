import gleam/http.{Get, Post, Put}
import gleam/io
import models/employee.{type Employee, type EmployeeIntermintermediate}
import repositories/cache.{type Cache}
import serializers/employee_serializer.{
  decode_employee, decode_new_employee, encode_employee,
}
import wisp.{type Request, type Response}

pub fn handle_request(ctx: Cache) {
  fn(req: Request) -> Response {
    // A new `app/web/people` module now contains the handlers and other functions
    // relating to the People feature of the application.
    //
    // The router module now only deals with routing, and dispatches to the
    // feature modules for handling requests.
    // 
    case req.method, wisp.path_segments(req) {
      Post, ["employee"] -> handle_post(req, ctx)
      _, _ -> wisp.not_found()
    }
  }
}

fn handle_post(req: Request, ctx: Cache) -> Response {
  use body <- wisp.require_string_body(req)
  case decode_new_employee(body) {
    Ok(new_employee) -> {
      let result = employee.new(new_employee.name, new_employee.birth)
      case result {
        Ok(employee) -> {
          cache.save(ctx, employee)
          let assert Ok(res) = cache.read_collection(ctx)
          io.debug(res)
          wisp.ok()
        }
        Error(_) -> wisp.bad_request()
      }
      // let assert Ok(res) = cache.read(ctx, employee.id)
    }
    Error(_) -> wisp.bad_request()
  }
  // bit_array.to_string(req.body)
}
// import gleam/bytes_builder.{type BytesBuilder}
// import gleam/http/request.{type Request}
// import gleam/http/response.{type Response}
// import gleam/io
// import gleam/string
// import gleam/result
// import models/employee.{type Employee}
// import repositories/cache.{type Cache}
// import serializers/employee_serializer.{decode_employee, encode_employee}
// import gleam/bit_array

// pub type HttpResponder {
//   HttpResponder(execute_request: fn() -> Response(BytesBuilder))
// }

// type BuilderObject(t) {
//   BuilderObject(request: Request(t), str: String, response_code: Int)
// }

// fn response_builder(payload: BuilderObject(t)) -> fn() -> Response(BytesBuilder) {
//   fn() -> Response(BytesBuilder) {
//     let body: BytesBuilder =
//       payload.str
//       |> bytes_builder.from_string

//     let content_type =
//       payload.request
//       |> request.get_header("content-type")
//       |> result.unwrap("application/json")

//     response.new(payload.response_code)
//     |> response.prepend_header("made-by", "Ivo")
//     |> response.prepend_header("content-type", content_type)
//     |> response.set_body(body)
//   }
// }

// fn handle_post(req: Request(t)) {
//   bit_array.to_string(req.body)
//   // io.debug(decode_employee(req.body))
// }

// // fn ivo(ctx: Cache) {
// //   let e: Employee = employee.new("Ivo Lejon", "1979")
// //   cache.save(ctx, e)
// //   // let assert Ok(res) = employee_repository.read(actor, e.id)
// //   let assert Ok(res) = cache.read_collection(ctx)
// //   io.debug(res)
// // }

// pub fn service(ctx: Cache) {
//   fn(req: Request(t)) -> Response(BytesBuilder) {
//     handle_post(req)
//     let path = request.path_segments(req)
//     let handler = case req.method, path {
//       // Get, ["employee"] ->
//       //   HttpResponder(
//       //     execute_request: response_builder(BuilderObject(
//       //       request,
//       //       "employee",
//       //       200,
//       //     )),
//       //   )
//       Get, ["employee"] ->
//         HttpResponder(
//           execute_request: response_builder(BuilderObject(req, "id", 200)),
//         )
//       Get, ["echo", id] ->
//         HttpResponder(
//           execute_request: response_builder(BuilderObject(req, id, 200)),
//         )
//       Get, ["hello"] ->
//         HttpResponder(
//           execute_request: response_builder(BuilderObject(req, "leo", 200)),
//         )
//       Get, [] ->
//         HttpResponder(
//           execute_request: response_builder(BuilderObject(req, "Not found", 404)),
//         )
//       _, _ ->
//         HttpResponder(
//           execute_request: response_builder(BuilderObject(req, "error", 500)),
//         )
//     }
//     handler.execute_request()
//   }
// }
