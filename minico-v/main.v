module main

import arrays

// state & method type
enum CoState {
	co_init
	co_run
	co_yield
	co_done
}

type CoTask = fn (mut co Co, data voidptr) int

// co struct
struct Co {
mut:
	state CoState
	func  CoTask  @[required]
	data  voidptr
}

fn Co.new(func CoTask, data voidptr) &Co {
	return &Co{
		state: .co_init
		func: func
		data: data
	}
}

fn (mut co Co) next() int {
	if co.state == .co_done {
		return 0
	}

	return co.func(mut co, co.data)
}

// callback data
struct FibData {
mut:
	n int
	a int
	b int
}

// callback method
fn fib_func(mut co Co, data voidptr) int {
	mut fib := unsafe { &FibData(data) } // cast void* to reference struct

	match co.state {
		.co_init {
			fib.a = 0
			fib.b = 1
			co.state = .co_run

			return fib.a
		}
		.co_run {
			if fib.n <= 0 {
				co.state = .co_done
				return 0
			}

			current := fib.a
			next := fib.a + fib.b

			fib.a = fib.b
			fib.b = next
			fib.n--

			co.state = .co_yield

			return current
		}
		.co_yield {
			co.state = .co_run

			return fib_func(mut co, data)
		}
		.co_done {
			return 0
		}
	}

	panic('Unexpected state branch')
}

// run
fn main() {
	fib := FibData{10, 0, 0}

	mut co := Co.new(fib_func, fib)
	mut vals := []int{}

	for co.state != .co_done {
		val := co.next()

		if co.state != .co_done {
			vals << val
		}
	}

	println(arrays.join_to_string[int](vals, ' ', fn (elem int) string {
		return elem.str()
	}))
}
