module main

fn main() {
	mut d := Deque.new[string]() //

	//
	println('-> deque.new = 0, 0')
	println('cap: ${d.cap()}')
	println('len: ${d.len()}')
	dump(d)

	//
	println('-> deque.push_back - foo, bar, barz')
	d.push_back('foo')
	d.push_back('bar')
	d.push_back('baz')

	println('-> deque.new = 16, 3')
	println('cap: ${d.cap()}')
	println('len: ${d.len()}')
	dump(d)

	//
	println('-> deque.{front,back} = foo , baz')
	println('front: ${d.front()!}') // foo
	println('back : ${d.back()!}') // baz

	//
	println('-> deque.push_{front,back} - hello, world')
	d.push_front('hello')
	d.push_back('world')

	//
	println('-> deque.push_{front,back} = foo')
	println('at: ${d.at(1)!}') // foo

	//
	println('-> deque.set - ooo')
	d.set(2, 'ooo')!

	//
	println('-> deque.index - barz = 3')
	println('index: ${d.index(fn (item string) bool {
		return item == 'baz'
	})}')

	//
	println('-> deque.rindex - barz = 3')
	println('rindex: ${d.rindex(fn (item string) bool {
		return item == 'baz'
	})}')

	//
	println('-> deque.insert - yoo at 2')
	d.insert(2, 'yoo')!

	//
	println('-> deque.remove = ooo')
	println('remove: ${d.remove(3)!}')

	//
	println('-> deque.for-loop')
	for d.len() != 0 {
		println('- ${d.pop_front()!}')
	}

	//
	println('-> deque.push_back - clear-1, clear-2')
	d.push_back('clear-1')
	d.push_back('clear-2')

	//
	println('-> deque.clear')
	d.clear()

	//
	println('-> dump')
	dump(d)

	//
	println('-> deque.set_min_capacity - 5')
	d.set_min_capacity(5)

	//
	println('-> dump')
	dump(d)

	//
	println('-> deque.push_back - apple, banana, carrot, date, egg')
	d.push_back('apple')
	d.push_back('banana')
	d.push_back('carrot')
	d.push_back('date')
	d.push_back('egg')

	//
	println('-> dump')
	dump(d)

	//
	println('-> deque.rotate - 1')
	d.rotate(1)

	//
	println('-> dump')
	dump(d)

	//
	println('-> deque.pop_front')
	for d.len() != 0 {
		println('- ${d.pop_front()!}')
	}
}
