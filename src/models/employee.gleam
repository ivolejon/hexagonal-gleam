import gluid

pub type Employee {
  Employee(id: String, name: String, birth: String)
}

pub type EmployeeIntermintermediate {
  EmployeeIntermintermediate(name: String, birth: String)
}

pub fn new(name: String, birth: String) -> Result(Employee, Nil) {
  let uuid: String = gluid.guidv4()
  Ok(Employee(id: uuid, name: name, birth: birth))
}

pub fn update_name(employee: Employee, new_name: String) -> Employee {
  Employee(..employee, name: new_name)
}
