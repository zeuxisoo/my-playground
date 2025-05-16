module main

import arrays

const min_capacity = 16

struct Deque[T] {
mut:
	buf     []T
	head    int
	tail    int
	count   int
	min_cap int
}

fn Deque.new[T](size ...int) &Deque[T] {
	mut capacity := 0
	mut minimum := 0

	if size.len >= 1 {
		capacity = size[0]

		if size.len >= 2 {
			minimum = size[1]
		}
	}

	mut min_cap := min_capacity
	for min_cap < minimum {
		min_cap <<= 1
	}

	buf := if capacity != 0 {
		mut buf_size := min_cap

		for buf_size < capacity {
			buf_size <<= 1
		}

		[]T{len: buf_size}
	} else {
		[]T{}
	}

	return &Deque[T]{
		buf: buf
		min_cap: min_cap
	}
}

fn (mut q Deque[T]) cap() int {
	return q.buf.len
}

fn (mut q Deque[T]) len() int {
	return q.count
}

fn (mut q Deque[T]) push_back(element T) {
	q.grow_if_full()

	q.buf[q.tail] = element

	q.tail = q.next(q.tail)

	q.count++
}

fn (mut q Deque[T]) push_front(element T) {
	q.grow_if_full()

	q.head = q.prev(q.head)

	q.buf[q.head] = element

	q.count++
}

fn (mut q Deque[T]) pop_back() !T {
	if q.count <= 0 {
		return error('deque.pop_back/0 called on empty queue')
	}

	// new tail position
	q.tail = q.prev(q.tail)

	// remove tail value
	ret := q.buf[q.tail]
	zero := T{}

	q.buf[q.tail] = zero
	q.count--

	//
	q.shrink_if_excess()

	return ret
}

fn (mut q Deque[T]) pop_front() !T {
	if q.count <= 0 {
		return error('deque.pop_front/0 called on empty queue')
	}

	//
	ret := q.buf[q.head]
	zero := T{}

	q.buf[q.head] = zero

	// new head position
	q.head = q.next(q.head)
	q.count--

	//
	q.shrink_if_excess()

	return ret
}

fn (mut q Deque[T]) back() !T {
	if q.count <= 0 {
		return error('deque.back/0 called when empty')
	}

	return q.buf[q.prev(q.tail)]
}

fn (mut q Deque[T]) front() !T {
	if q.count <= 0 {
		return error('deque.front/0 called when empty')
	}

	return q.buf[q.head]
}

fn (mut q Deque[T]) next(i int) int {
	return (i + 1) & (q.buf.len - 1)
}

fn (mut q Deque[T]) prev(i int) int {
	return (i - 1) & (q.buf.len - 1)
}

fn (mut q Deque[T]) at(i int) !T {
	if i < 0 || i >= q.count {
		return error(q.out_of_range_text('at/1', i, q.len()))
	}

	return q.buf[(q.head + i) & (q.buf.len - 1)]
}

fn (mut q Deque[T]) set(i int, item T) ! {
	if i < 0 || i >= q.count {
		return error(q.out_of_range_text('set/2', i, q.len()))
	}

	q.buf[(q.head + i) & (q.buf.len - 1)] = item
}

fn (mut q Deque[T]) index(f fn (T) bool) int {
	if q.len() > 0 {
		mod_bits := q.buf.len - 1

		for i := 0; i < q.count; i++ {
			if f(q.buf[(q.head + i) & mod_bits]) {
				return i
			}
		}
	}

	return -1
}

fn (mut q Deque[T]) rindex(f fn (T) bool) int {
	if q.len() > 0 {
		mod_bits := q.buf.len - 1

		for i := q.count - 1; i >= 0; i-- {
			if f(q.buf[(q.head + i) & mod_bits]) {
				return i
			}
		}
	}

	return -1
}

fn (mut q Deque[T]) insert(at int, item T) ! {
	if at < 0 || at > q.count {
		return error(q.out_of_range_text('insert/2', at, q.len()))
	}

	if at * 2 < q.count {
		q.push_front(item)

		mut front := q.head

		for i := 0; i < at; i++ {
			next := q.next(front)

			q.buf[front], q.buf[next] = q.buf[next], q.buf[front]

			front = next
		}

		return
	}

	//
	swaps := q.count - at

	q.push_back(item)

	mut back := q.prev(q.tail)

	for i := 0; i < swaps; i++ {
		prev := q.prev(back)

		q.buf[back], q.buf[prev] = q.buf[prev], q.buf[back]

		back = prev
	}
}

fn (mut q Deque[T]) remove(at int) !T {
	if at < 0 || at >= q.len() {
		return error(q.out_of_range_text('remove/1', at, q.len()))
	}

	mut rm := (q.head + at) & (q.buf.len - 1)

	if at * 2 < q.count {
		for i := 0; i < at; i++ {
			prev := q.prev(rm)

			q.buf[prev], q.buf[rm] = q.buf[rm], q.buf[prev]

			rm = prev
		}
		return q.pop_front()!
	}

	//
	swaps := q.count - at - 1

	for i := 0; i < swaps; i++ {
		next := q.next(rm)

		q.buf[rm], q.buf[next] = q.buf[next], q.buf[rm]

		rm = next
	}

	return q.pop_back()!
}

fn (mut q Deque[T]) clear() {
	zero := T{}
	mod_bits := q.buf.len - 1
	head := q.head

	for i := 0; i < q.len(); i++ {
		q.buf[(head + i) & mod_bits] = zero
	}

	q.head = 0
	q.tail = 0
	q.count = 0
}

fn (mut q Deque[T]) rotate(n int) {
	if q.len() <= 1 {
		return
	}

	//
	mut m := n % q.count

	if m == 0 {
		return
	}

	//
	mod_bits := q.buf.len - 1

	if q.head == q.tail {
		q.head = (q.head + n) & mod_bits
		q.tail = q.head

		return
	}

	zero := T{}

	if m < 0 {
		for ; m < 0; m++ {
			q.head = (q.head - 1) & mod_bits
			q.tail = (q.tail - 1) & mod_bits

			q.buf[q.head] = q.buf[q.tail]
			q.buf[q.tail] = zero
		}

		return
	}

	for ; m > 0; m-- {
		q.buf[q.tail] = q.buf[q.head]
		q.buf[q.head] = zero

		q.head = (q.head + 1) & mod_bits
		q.tail = (q.tail + 1) & mod_bits
	}
}

fn (mut q Deque[T]) set_min_capacity(min_capacity_exp u32) {
	new_min_capacity_exp := 1 << min_capacity_exp

	q.min_cap = if new_min_capacity_exp > min_capacity {
		new_min_capacity_exp
	} else {
		min_capacity
	}
}

fn (mut q Deque[T]) grow_if_full() {
	if q.count != q.buf.len {
		return
	}

	if q.buf.len == 0 {
		if q.min_cap == 0 {
			q.min_cap = min_capacity
		}

		q.buf = []T{len: q.min_cap}

		return
	}

	q.resize()
}

fn (mut q Deque[T]) resize() {
	mut new_buf := []T{len: int(u32(q.count) << 1)}

	if q.tail > q.head {
		arrays.copy(mut new_buf, q.buf[q.head..q.tail])
	} else {
		n := arrays.copy(mut new_buf, q.buf[q.head..])

		arrays.copy(mut new_buf[n..], q.buf[..q.tail])
	}

	q.head = 0
	q.tail = q.count
	q.buf = new_buf
}

fn (mut q Deque[T]) shrink_if_excess() {
	if q.buf.len > q.min_cap && int(u32(q.count) << 2) == q.buf.len {
		q.resize()
	}
}

@[inline]
fn (q Deque[T]) out_of_range_text(method string, i int, len int) string {
	return 'deque.${method} index out of range ${i} with length ${len}'
}
