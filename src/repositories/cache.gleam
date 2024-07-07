import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import models/employee.{type Employee}

const timeout = 100

type Store =
  Dict(String, Employee)

pub type Cache =
  Subject(Message(Employee))

pub type Message(value) {
  Save(value: Employee)
  Read(id: String, reply_with: Subject(Result(Employee, Nil)))
  ReadCollection(reply_with: Subject(Result(List(Employee), Nil)))
  Delete(id: String, reply_with: Subject(Result(Nil, Nil)))
  Shutdown
}

fn handle_message(
  message: Message(value),
  store: Store,
) -> actor.Next(Message(value), Store) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Save(employee) -> {
      let store = dict.insert(store, employee.id, employee)
      actor.continue(store)
    }
    Read(id, return_type) -> {
      process.send(return_type, dict.get(store, id))
      actor.continue(store)
    }
    ReadCollection(return_type) -> {
      process.send(return_type, Ok(dict.values(store)))
      actor.continue(store)
    }
    Delete(id, return_type) -> {
      let _ = dict.drop(store, [id])
      process.send(return_type, Ok(Nil))
      actor.continue(store)
    }
  }
}

/// Create a new cache.
pub fn new() -> Result(Cache, actor.StartError) {
  actor.start(dict.new(), handle_message)
}

pub fn save(cache: Cache, employee: Employee) -> Nil {
  process.send(cache, Save(employee))
}

pub fn read(cache: Cache, id: String) -> Result(Employee, Nil) {
  actor.call(cache, Read(id, _), timeout)
}

pub fn read_collection(cache: Cache) -> Result(List(Employee), Nil) {
  actor.call(cache, ReadCollection(_), timeout)
}

pub fn delete(cache: Cache, id: String) -> Result(Nil, Nil) {
  actor.call(cache, Delete(id, _), timeout)
}
