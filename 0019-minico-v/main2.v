module main

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
	label int
}

fn Co.new(func CoTask, data voidptr) &Co {
	return &Co{
		state: .co_init
		func: func
		data: data
		label: 0
	}
}

fn (mut co Co) next() int {
	if co.state == .co_done {
		return 0
	}

	co.state = .co_run

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

	match co.label {
		0 {
			if fib.n > 0 {
				current := fib.a
				next := fib.a + fib.b

				fib.a = fib.b
				fib.b = next
				fib.n--

				co.state = .co_yield

				if current == 5 {
					co.label = 1
				}

				return current
			}
		}
		1 {
			println('\nHi you got 5!')

			co.label = 0

			return fib.a
		}
		else {
			panic('Unexpected type of label got ${co.label}')
		}
	}

	co.state = .co_done

	return 0
}

// run
fn main() {
	fib := FibData{10, 0, 1}

	mut co := Co.new(fib_func, fib)

	for co.state != .co_done {
		val := co.next()

		if co.state != .co_done {
			print('${val} ')
		}
	}

	println('')
}
