import gleam/dynamic.{field}
import gleam/json.{object, string}
import models/employee.{type Employee, Employee}

pub fn decode_employee(
  json_string: String,
) -> Result(Employee, json.DecodeError) {
  let employee_decoder =
    dynamic.decode3(
      Employee,
      field("id", of: dynamic.string),
      field("name", of: dynamic.string),
      field("birth", of: dynamic.string),
    )

  json.decode(from: json_string, using: employee_decoder)
}

pub fn encode_employee(employee: Employee) -> String {
  object([
    #("id", string(employee.id)),
    #("name", string(employee.name)),
    #("birth", string(employee.birth)),
  ])
  |> json.to_string
}
