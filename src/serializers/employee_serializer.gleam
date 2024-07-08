import gleam/dynamic.{field, list}
import gleam/json.{object, string}
import gleam/list
import gleam/string
import models/employee.{
  type Employee, type EmployeeIntermintermediate, Employee,
  EmployeeIntermintermediate,
}

pub fn encode_employee_collection(employees: List(Employee)) -> String {
  let json_list =
    list.map(employees, fn(e: Employee) {
      object([
        #("id", string(e.id)),
        #("name", string(e.name)),
        #("birth", string(e.birth)),
      ])
      |> json.to_string
    })
    |> string.join(", ")

  string.join(["[", json_list, "]"], "")
}

pub fn decode_new_employee(
  json_string: String,
) -> Result(EmployeeIntermintermediate, json.DecodeError) {
  let employee_decoder =
    dynamic.decode2(
      EmployeeIntermintermediate,
      field("name", of: dynamic.string),
      field("birth", of: dynamic.string),
    )

  json.decode(from: json_string, using: employee_decoder)
}
