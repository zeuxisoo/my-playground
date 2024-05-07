module base62

import math { floor }
import math.big
import maps

const base = 62
const base_big_int = big.integer_from_int(62)
const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('')
const indices = maps.invert(maps.from_array(alphabet))

fn get_index(index string) !int {
	return base62.indices[index] or {
		return error('Unexpected index for Base62 encoding: `${index}`')
	}
}

// encode
pub fn encode_string(value string) !string {
	return encode_bytes(value.bytes())!
}

pub fn encode_bytes(bytes []u8) !string {
	if bytes.len == 0 {
		return ''
	}

	mut value := big.one_int

	for b in bytes {
		value = value.left_shift(8).bitwise_or(big.integer_from_int(b))
	}

	return encode_big_int(value)!
}

pub fn encode_int(value int) !string {
	if value < 0 {
		return error('The integer must be non-negative.')
	}

	if value == 0 {
		return base62.alphabet[0]
	}

	mut encoded_string := ''
	mut integer_clone := value

	for integer_clone > 0 {
		encoded_string = base62.alphabet[integer_clone % base62.base] + encoded_string
		integer_clone = int(floor(f64(integer_clone / base62.base)))
	}

	return encoded_string
}

pub fn encode_big_int(big_int big.Integer) !string {
	if big_int < big.zero_int {
		return error('The bigint must be non-negative.')
	}

	if big_int == big.zero_int {
		return base62.alphabet[0]
	}

	mut encoded_string := ''
	mut big_int_clone := big_int

	for (big_int_clone > big.zero_int) {
		big_int_index := (big_int_clone % base62.base_big_int).int()

		encoded_string = base62.alphabet[big_int_index] + encoded_string

		big_int_clone = big_int_clone / big.integer_from_int(base62.base)
	}

	return encoded_string
}

// decode
pub fn decode_string(value string) !string {
	return decode_bytes(value)!.bytestr()
}

pub fn decode_bytes(value string) ![]u8 {
	if value == '' {
		return []u8{}
	}

	mut big_int := decode_big_int(value)!
	mut byte_array := []u8{}

	for big_int > big.zero_int {
		byte_array << u8(big_int.bitwise_and(big.integer_from_int(0xFF)).int())

		big_int = big_int.right_shift(8)
	}

	return byte_array.reverse()[2..] // remove 0 and 1
}

pub fn decode_int(value string) !int {
	mut int_result := 0

	for index in value.split('') {
		int_result = (int_result * base62.base) + get_index(index)!
	}

	return int_result
}

pub fn decode_big_int(value string) !big.Integer {
	mut big_int := big.zero_int

	for index in value.split('') {
		big_int = (big_int * base62.base_big_int) + big.integer_from_int(get_index(index)!)
	}

	return big_int
}
