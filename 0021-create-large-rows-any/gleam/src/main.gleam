import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/string
import gleam/string_builder
import simplifile
// import gleam/result

// https://www.erlang.org/doc/apps/erts/erlang.html#t:time_unit/0
pub type TimeUnit {
    Second
    Millisecond
    Microsecond
    Nanosecond
    Native
    PerfCounter
}

@external(erlang, "os", "system_time")
pub fn now() -> Int

@external(erlang, "os", "system_time")
pub fn now_format(a: TimeUnit) -> Int

const max_row = 1_000
const chunk_row = 100

fn create_insert_statements(start: Int, end: Int) -> task.Task(List(String)) {
    task.async(fn() {
        list.range(start, end - 1)
            |> list.map(fn(i) {
                string_builder.from_strings([
                    "insert into table (id, a, b, t) values (",
                    string.join([
                        int.to_string(i),
                        "1",
                        "2",
                        int.to_string(now_format(PerfCounter))
                    ], with: ", "),
                    ");"
                ])
                |> string_builder.to_string
            })
    })
}

pub fn main() {
    // io.debug(list.sized_chunk(list.range(0, max_row), chunk_row))

    list.range(0, int.subtract(max_row / chunk_row, 1))
        |> list.map(fn(i) {
            let start = i * chunk_row
            let end = int.min(i * chunk_row + chunk_row, max_row)

            io.println("Sending " <> int.to_string(start) <> "... " <> int.to_string(end))

            create_insert_statements(start, end)
        })
        |> list.map(task.await_forever)
        |> list.map(fn(statements) {
            let content = string.join(statements, "\n") <> "\n"

            simplifile.append(content, to: "./inserts.txt")

            // case simplifile.create_file("./insert.txt") {
            //     Ok(Nil) -> simplifile.write(content, to: "./insert.txt")
            //     Error(_) -> {
            //         // io.debug(simplifile.describe_error(e))
            //         simplifile.append(content, to: "./insert.txt")
            //     }
            // }

            // case result.is_ok(simplifile.create_file("./insert.txt")) {
            //     True -> simplifile.write(content, to: "./insert.txt")
            //     False -> simplifile.append(content, to: "./insert.txt")
            // }

            // simplifile.create_file("./insert.txt")
            //     |> result.then(fn(_) { // or result.try
            //         simplifile.write(content, to: "./insert.txt")
            //     })
            //     |> result.try_recover(fn(_) {
            //         simplifile.append(content, to: "./insert.txt")
            //     })
        })
}
