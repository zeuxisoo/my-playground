module main

import time

fn test_generate_length() {
	mut generator := &BlockGenerator{}

	generator.add(0)
	generator.add(1)

	assert generator.blocks.len == 2
}

fn test_generate_bpm() {
	mut generator := &BlockGenerator{}

	generator.add(0)
	generator.add(1)
	generator.add(2)

	assert generator.blocks[0].bpm == 0
	assert generator.blocks[1].bpm == 1
	assert generator.blocks[2].bpm == 2
}

fn test_generate_first_block() {
	mut generator := &BlockGenerator{}

	generator.add(0)

	assert generator.blocks[0].index == 0
	assert generator.blocks[0].timestamp == time.unix(generator.blocks[0].timestamp.i64()).unix_time().str()
	assert generator.blocks[0].bpm == 0
	assert generator.blocks[0].prev_hash == ''
	assert generator.blocks[0].hash == ''
}

fn test_generate_second_block() {
	mut generator := &BlockGenerator{}

	generator.add(0)
	generator.add(10)

	assert generator.blocks[1].index == 1
	assert generator.blocks[1].timestamp == time.unix(generator.blocks[1].timestamp.i64()).unix_time().str()
	assert generator.blocks[1].bpm == 10
	assert generator.blocks[1].prev_hash == ''
	assert generator.blocks[1].hash != ''
}

fn test_generate_prev_hash() {
	mut generator := &BlockGenerator{}

	generator.add(0)
	generator.add(10) // 1.prev_hash -> ''
	generator.add(11) // 2.prev_hash -> 1
	generator.add(12) // 3.prev_hash -> 2
	generator.add(13) // 4.prev_hash -> 3

	assert generator.blocks[1].hash == generator.blocks[2].prev_hash
	assert generator.blocks[2].hash == generator.blocks[3].prev_hash
	assert generator.blocks[3].hash == generator.blocks[4].prev_hash
}
