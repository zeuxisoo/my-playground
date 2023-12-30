module main

fn create_deque() &Deque[string] {
	return Deque.new[string]()
}

fn create_foo_bar_barz_deque() &Deque[string] {
	mut deque := create_deque()
	mut items := ['foo', 'bar', 'barz']

	for item in items {
		deque.push_back(item)
	}

	return deque
}

fn test_init_deque() {
	mut deque := create_deque()

	assert deque == &Deque{
		buf: []string{}
		head: 0
		tail: 0
		count: 0
		min_cap: 16
	}
}

fn test_init_size_deque() {
	mut deque1 := Deque.new[string](0, 64)
	mut deque2 := Deque.new[string](128, 64)

	assert deque1.min_cap == 64
	assert deque2.buf.len == 128
}

fn test_cap() {
	mut deque := create_deque()

	assert deque.cap() == 0
}

fn test_len() {
	mut deque := create_deque()

	assert deque.len() == 0
}

fn test_push_back() {
	mut deque := create_foo_bar_barz_deque()

	deque.push_back('world')

	assert deque.len() == 4
	assert deque.back()! == 'world'
}

fn test_push_front() {
	mut deque := create_foo_bar_barz_deque()

	deque.push_front('hello')

	assert deque.len() == 4
	assert deque.front()! == 'hello'
}

fn test_pop_back() {
	mut deque := create_foo_bar_barz_deque()

	assert deque.pop_back()! == 'barz'

	deque.push_back('world')

	assert deque.pop_back()! == 'world'
}

fn test_pop_front() {
	mut deque := create_foo_bar_barz_deque()

	assert deque.pop_front()! == 'foo'

	deque.push_back('hello')

	assert deque.pop_back()! == 'hello'
}

fn test_back() {
	mut deque := create_foo_bar_barz_deque()

	deque.pop_back()!
	deque.pop_back()!
	deque.push_back('world')
	deque.push_front('hello')
	deque.pop_back()!

	assert deque.back()! == 'foo'
}

fn test_front() {
	mut deque := create_foo_bar_barz_deque()

	deque.pop_front()!
	deque.pop_front()!
	deque.push_front('hello')
	deque.push_back('world')
	deque.pop_front()!

	assert deque.front()! == 'barz'
}

fn test_next() {
	mut deque := create_foo_bar_barz_deque()

	// ring
	assert deque.next(15) == 0
}

fn test_prev() {
	mut deque := create_foo_bar_barz_deque()

	// ring
	assert deque.prev(0) == 15
}

fn test_at() {
	mut deque := create_foo_bar_barz_deque()

	assert deque.at(2)! == 'barz'

	deque.at(99) or { assert err.msg() == 'deque.at/1 index out of range 99 with length 3' }
}

fn test_set() {
	mut deque := create_foo_bar_barz_deque()

	deque.set(1, 'bary')!

	assert deque.at(1)! == 'bary'

	deque.set(99, 'ooo') or {
		assert err.msg() == 'deque.set/2 index out of range 99 with length 3'
	}
}

fn test_index() {
	mut deque := create_foo_bar_barz_deque()

	index := deque.index(fn (item string) bool {
		return item == 'bar'
	})

	assert index == 1
}

fn test_rindex() {
	mut deque := create_foo_bar_barz_deque()

	deque.push_front('hello')

	index := deque.rindex(fn (item string) bool {
		return item == 'foo'
	})

	// ring
	assert index == 1
}

fn test_insert() {
	mut deque := create_foo_bar_barz_deque()

	deque.insert(1, 'bary')!

	assert deque.len() == 4
	assert deque.at(0)! == 'foo'
	assert deque.at(1)! == 'bary'
	assert deque.at(2)! == 'bar'
	assert deque.at(3)! == 'barz'

	deque.insert(99, 'ooo') or {
		assert err.msg() == 'deque.insert/2 index out of range 99 with length 4'
	}
}

fn test_remove() {
	mut deque := create_foo_bar_barz_deque()

	deque.remove(1)!

	assert deque.len() == 2

	deque.remove(99) or { assert err.msg() == 'deque.remove/1 index out of range 99 with length 2' }
}

fn test_clear() {
	mut deque := create_foo_bar_barz_deque()

	deque.clear()

	assert deque.len() == 0
}

fn test_rotate() {
	rotate_deque := fn (rotate_index int) ![]string {
		mut deque := create_foo_bar_barz_deque()

		// 0: ['foo', 'bar', 'barz'] -> ['foo', 'bar', 'barz']
		// 1: ['foo', 'bar', 'barz'] -> ['bar', 'barz', 'foo']
		// 2: ['foo', 'bar', 'barz'] -> ['barz', 'foo', 'bar']
		deque.rotate(rotate_index)

		mut items := []string{}
		for deque.len() != 0 {
			items << deque.pop_front()!
		}

		return items
	}

	assert rotate_deque(0)! == ['foo', 'bar', 'barz']
	assert rotate_deque(1)! == ['bar', 'barz', 'foo']
	assert rotate_deque(2)! == ['barz', 'foo', 'bar']
}

fn test_set_min_capacity() {
	mut deque := create_deque()

	assert deque.min_cap == 16

	deque.set_min_capacity(5)

	assert deque.min_cap == 32
}

fn test_grow_if_full() {
	mut deque := create_deque()

	deque.min_cap = 0

	assert deque.buf.len == 0
	assert deque.min_cap == 0

	deque.grow_if_full()

	assert deque.buf.len == 16
	assert deque.min_cap == 16
}
