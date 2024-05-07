module base62

import math.big

fn test_encode_decode_bytes_is_equals() {
	input := [u8(10), 20, 30, 40, 255]
	encoded := encode_bytes(input)!
	decoded := decode_bytes(encoded)!

	assert decoded == input
}

fn test_encode_decode_string_are_equals() {
	test_strings := {
		'Hello, World!':                                         '8nlogx6nlNdJhVT24v'
		'Another example🏴':                                     'B6f8m2TtOhNkJuVfeJVXhKTPAi'
		'1234567890':                                            '7CipUfMcknk2uu'
		'🦄':                                                    '95s3vg'
		'😊🚀🌟💥':                                              'F7782ZaAxP6MFPZUluW18H'
		'Special characters ~`!@#$%^&*()_+-={}[]:";\'<>?,./|\\': 'BU3kOcSFw49tim4FMGq22KElf62dgQ6YAeCoc2XVcK32JQ5LoO2TfOn2cwCL5PPeRU9BE'
		'':                                                      ''
		'0':                                                     '4u'
		'000x':                                                  '5ZNTk8'
	}

	for input, expected in test_strings {
		encoded := encode_string(input)!
		decoded := decode_string(encoded)!

		assert encoded == expected
		assert input == decoded
	}
}

fn test_encode_decode_int_is_equals() {
	input := 1_234_567_890
	encoded := encode_int(input)!
	decoded := decode_int(encoded)!

	assert decoded == input
}

fn test_encode_decode_big_int_is_equals() {
	input := big.integer_from_string('123456789012345678901234567890')!
	encoded := encode_big_int(input)!
	decoded := decode_big_int(encoded)!

	assert decoded == input
}

fn test_encode_byte_when_single_byte() {
	input := [u8(0), 0, 0, 1, 9, 10, 35, 61, 62, 255]
	encoded := encode_bytes(input)!
	decoded := decode_bytes(encoded)!

	assert decoded == input
}

fn test_encode_string_when_unicode() {
	input := '😊🚀🌟💥'
	encoded := encode_string(input)!
	decoded := decode_string(encoded)!

	assert decoded == input
}

fn test_encode_int_when_small_and_large_number() {
	inputs := [
		0,
		1,
		12,
		123,
		1234,
		12_345,
		123_456,
		1_234_567,
		12_345_678,
		max_i32,
	]

	for input in inputs {
		encoded := encode_int(input)!
		decoded := decode_int(encoded)!

		assert decoded == input
	}
}

fn test_encode_big_int_when_very_large_integer() {
	inputs := [
		big.integer_from_int(0),
		big.integer_from_int(1),
		big.integer_from_u64(12_345_678_901_234_567_890),
		big.integer_from_string('98765432109876543210')!,
		big.integer_from_radix('1FFFFFFFFFFFFF', 16)!,
		big.integer_from_radix('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 16)!,
	]

	for input in inputs {
		encoded := encode_big_int(input)!
		decoded := decode_big_int(encoded)!

		assert decoded == input
	}
}
