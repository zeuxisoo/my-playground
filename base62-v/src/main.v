module main

import math.big
import base62

fn main() {
	dump(base62.encode_string('123')!)
	dump(base62.decode_string('1LvG7')!)

	dump(base62.encode_string('你好嗎, HelloWorld, !@#$%^&*()')!)
	dump(base62.decode_string('7ecQ7gAmQLQMMnXautbfKAMQyevT54xVOb3inPdaEAT1d')!)

	dump(base62.encode_int(5678)!)
	dump(base62.decode_int('1Ta')!)

	dump(base62.encode_big_int(big.integer_from_string('99876543210987654321')!)!)
	dump(base62.decode_big_int('1uzzcuBYr9MX')!)
}
