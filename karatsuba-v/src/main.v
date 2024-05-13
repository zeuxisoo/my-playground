module main

import math
import math.big

fn karatsuba(num1 big.Integer, num2 big.Integer) !big.Integer {
	//
	mut num1_str := num1.str()
	mut num2_str := num2.str()

	//
	if num1_str[0] == `-` {
		return karatsuba(num1.neg(), num2)!.neg()
	}

	if num2_str[0] == `-` {
		return karatsuba(num1, num2.neg())!.neg()
	}

	//
	if num1 < big.integer_from_int(10) || num2 < big.integer_from_int(10) {
		return num1 * num2
	}

	//
	max_len := math.max(num1_str.len, num2_str.len)

	//
	num1_str = '0'.repeat(max_len)#[..-num1_str.len] + num1_str
	num2_str = '0'.repeat(max_len)#[..-num2_str.len] + num2_str

	//
	split_pos := max_len / 2
	high1 := big.integer_from_string(num1_str#[..-split_pos])!
	low1 := big.integer_from_string(num1_str#[-split_pos..])!
	high2 := big.integer_from_string(num2_str#[..-split_pos])!
	low2 := big.integer_from_string(num2_str#[-split_pos..])!

	//
	z0 := karatsuba(low1, low2)!
	z2 := karatsuba(high1, high2)!
	z1 := karatsuba(low1 + high1, low2 + high2)!

	//
	x1 := big.integer_from_int(10).pow(u32(2 * split_pos))
	x2 := (z1 - z2 - z0)
	x3 := big.integer_from_int(10).pow(u32(split_pos))

	//
	return z2 * x1 + x2 * x3 + z0
}

fn main() {
	num1 := big.integer_from_string('1234')!
	num2 := big.integer_from_string('5678')!

	result := karatsuba(num1, num2)!

	dump(result)
}
