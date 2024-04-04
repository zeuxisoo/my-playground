module main

import crypto.sha1
import math.big
import math
import arrays

struct BloomFilter {
	size          int
	number_hashes int
	salt          string
mut:
	bit_array []int
}

fn new_bloom_filter(size int, number_hashes int, salt string) &BloomFilter {
	return &BloomFilter{
		size: size
		number_hashes: number_hashes
		salt: salt
		bit_array: []int{len: size, init: 0}
	}
}

fn (mut bf BloomFilter) add(element string) ! {
	for i in 0 .. bf.number_hashes {
		digest := sha1.hexhash('${bf.salt}${element}${i}')
		index := big.integer_from_radix(digest, 16)! % big.integer_from_int(bf.size)

		bf.bit_array[index.int()] = 1
	}
}

fn (bf BloomFilter) lookup(element string) !bool {
	for i in 0 .. bf.number_hashes {
		digest := sha1.hexhash('${bf.salt}${element}${i}')
		index := big.integer_from_radix(digest, 16)! % big.integer_from_int(bf.size)

		bit := bf.bit_array[index.int()] or { 0 }

		if bit == 0 {
			return false
		}
	}

	return true
}

fn (bf BloomFilter) estimate_dataset_size() !f64 {
	m := bf.size
	k := bf.number_hashes

	// cast to double value first ensure result is double value same as python
	n := -(f64(m) / k) * math.log(1 - arrays.sum(bf.bit_array)! / f64(m))

	return n
}

fn (bf BloomFilter) union_with(other BloomFilter) !&BloomFilter {
	if bf.size != other.size || bf.number_hashes != other.number_hashes {
		return error('Both filters must have the same size and hash count')
	}

	mut new_bit_array := []int{}
	for bits in zip(bf.bit_array, other.bit_array) {
		new_bit_array << bits[0] | bits[1]
	}

	mut result := new_bloom_filter(bf.size, bf.number_hashes, '')
	result.bit_array = new_bit_array

	return result
}

fn (bf BloomFilter) intersection_with(other BloomFilter) !&BloomFilter {
	if bf.size != other.size || bf.number_hashes != other.number_hashes {
		return error('Both filters must have the same size and hash count')
	}

	mut new_bit_array := []int{}
	for bits in zip(bf.bit_array, other.bit_array) {
		new_bit_array << bits[0] & bits[1]
	}

	mut result := new_bloom_filter(bf.size, bf.number_hashes, '')
	result.bit_array = new_bit_array

	return result
}

fn zip[T](items1 []T, items2 []T) [][]T {
	mut new_items := [][]T{}

	for i, item in items1 {
		new_items << [item, items2[i]]
	}

	return new_items
}

fn main() {
	coffees := [
		'Iced Coffee',
		'Iced Coffee with Milk',
		'Espresso',
		'Espresso Macchiato',
		'Flat White',
		'Latte Macchiato',
		'Cappuccino',
		'Mocha',
	]

	mut bloom := new_bloom_filter(20, 2, '')
	for drink in coffees {
		bloom.add(drink)!

		println(bloom.bit_array)
	}

	println('---Experiment #1---')
	println(bloom.lookup('Flat White')!)
	println(bloom.lookup('Americano')!)
	println(bloom.estimate_dataset_size()!)

	//
	more_coffees := [
		'Iced Espresso',
		'Flat White',
		'Cappuccino',
		'Frappuccino',
		'Latte',
	]

	mut bloom2 := new_bloom_filter(20, 2, '')
	for drink in more_coffees {
		bloom2.add(drink)!
	}

	bloom3 := bloom2.union_with(bloom)!
	println('---Experiment #2---')
	println(bloom3.lookup('Mocha')!)
	println(bloom3.lookup('Frappuccino')!)
	println(bloom3.estimate_dataset_size()!)

	bloom4 := bloom2.intersection_with(bloom)!
	println('---Experiment #3---')
	println(bloom4.lookup('Mocha')!)
	println(bloom4.lookup('Flat White')!)
	println(bloom4.estimate_dataset_size()!)
}
