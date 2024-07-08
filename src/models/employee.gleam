import gleam/dynamic.{field}
import gleam/json.{object, string}

pub type Employee {
  Employee(id: String, name: String, birth: String)
}

pub type EmployeeIntermintermediate {
  EmployeeIntermintermediate(name: String, birth: String)
}

pub fn to_json(employee: Employee) -> String {
  object([
    #("id", string(employee.id)),
    #("name", string(employee.name)),
    #("birth", string(employee.birth)),
  ])
  |> json.to_string
}

pub fn from_json(json_string: String) -> Result(Employee, json.DecodeError) {
  let employee_decoder =
    dynamic.decode3(
      Employee,
      field("id", of: dynamic.string),
      field("name", of: dynamic.string),
      field("birth", of: dynamic.string),
    )
  json.decode(from: json_string, using: employee_decoder)
}
