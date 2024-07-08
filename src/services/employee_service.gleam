import gluid
import models/employee.{type Employee, Employee}

pub fn new(name: String, birth: String) -> Result(Employee, Nil) {
  let uuid: String = gluid.guidv4()
  Ok(Employee(id: uuid, name: name, birth: birth))
}

pub fn update(
  employee: Employee,
  updated_employee: Employee,
) -> Result(Employee, Nil) {
  Ok(
    Employee(
      ..employee,
      name: updated_employee.name,
      birth: updated_employee.birth,
    ),
  )
}
