module main

import time
import crypto.sha256
import x.json2

struct Block {
	index     int
	timestamp string
	bpm       int
	prev_hash string
mut:
	hash string
}

struct BlockGenerator {
mut:
	blocks []Block
}

fn (bg BlockGenerator) new_block_generator() &BlockGenerator {
	return &BlockGenerator{
		blocks: []Block{}
	}
}

fn (bg BlockGenerator) calculate_hash(block Block) string {
	return sha256.hexhash('${block.index}${block.timestamp}${block.bpm}${block.prev_hash}')
}

fn (bg BlockGenerator) calcuate_current_time_utc() string {
	return time.now().unix_time().str()
}

fn (bg BlockGenerator) generate_block(old_block Block, bpm int) Block {
	mut block := Block{
		index: old_block.index + 1
		timestamp: bg.calcuate_current_time_utc()
		bpm: bpm
		prev_hash: old_block.hash
	}

	block.hash = bg.calculate_hash(block)

	return block
}

fn (bg BlockGenerator) is_block_valid(new_block Block, old_block Block) bool {
	// vfmt off
	return new_block.index == old_block.index + 1
		&& new_block.prev_hash == old_block.hash
		&& bg.calculate_hash(new_block) == new_block.hash
	// vfmt on
}

fn (mut bg BlockGenerator) switch_chain(new_chain []Block) {
	if new_chain.len > bg.blocks.len {
		bg.blocks = new_chain
	}
}

fn (mut bg BlockGenerator) add(bpm int) {
	if bg.blocks.len <= 0 {
		bg.blocks << Block{
			index: 0
			timestamp: bg.calcuate_current_time_utc()
			bpm: 0
			prev_hash: ''
			hash: ''
		}
	} else {
		old_block := bg.blocks.last()
		new_block := bg.generate_block(old_block, bpm)

		if bg.is_block_valid(new_block, old_block) {
			mut new_chain := []Block{}

			for blk in bg.blocks {
				new_chain << blk
			}
			new_chain << new_block

			bg.switch_chain(new_chain)
		}
	}
}

fn (bg BlockGenerator) to_json(pretty bool) string {
	return if pretty == true {
		json2.encode_pretty(bg.blocks)
	} else {
		json2.encode(bg.blocks)
	}
}

fn main() {
	mut generator := &BlockGenerator{}

	generator.add(0)
	generator.add(10)
	generator.add(11)
	generator.add(12)

	println(generator.to_json(true))
}
