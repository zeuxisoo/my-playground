module main

import math
import os
import time
import strings

const max_row = 1_000 // 1_000_000
const chunk_row = 100 // max_row / 100

fn create_insert_statements(start int, end int) string {
	mut builder := strings.new_builder(0)

	for i in start .. end {
		builder.writeln('insert into table (id, a, b, t) values (${i}, 1, 2, \'${time.now().unix_micro()}\');')
	}

	return builder.str()
}

fn main() {
	println('Gen ...')

	mut threads := []thread string{cap: max_row / chunk_row} // ceil?
	for i := 0; i < max_row; i += chunk_row {
		chunk_end := math.min(i + chunk_row, max_row)

		println('${i}..${chunk_end}')

		threads << spawn create_insert_statements(i, chunk_end)
	}
	statements := threads.wait()

	os.write_file('./insert.txt', statements.join(''))!
}
