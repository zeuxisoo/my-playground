module main

struct Tokenizer {
	code []rune
mut:
	ptr        int
	iter_token Token
}

fn Tokenizer.new(code string) Tokenizer {
	return Tokenizer{
		code: code.runes()
		ptr: 0
	}
}

fn (mut self Tokenizer) tokenize() ![]Token {
	mut tokens := []Token{}

	for {
		token := self.next_token()!

		tokens << token

		if token.kind == TokenType.eof {
			break
		}
	}

	return tokens
}

fn (mut self Tokenizer) next_token() !Token {
	for self.ptr < self.code.len && self.code[self.ptr] == ` ` {
		self.ptr += 1
	}

	if self.ptr == self.code.len {
		return Token{TokenType.eof, 'eof'}
	}

	chr := self.code[self.ptr]

	if chr == `+` {
		self.ptr += 1
		return Token{TokenType.plus, chr.str()}
	} else if chr == `-` {
		self.ptr += 1
		return Token{TokenType.minus, chr.str()}
	} else if u8(chr).is_digit() {
		integer := self.consume_int()

		if self.ptr < self.code.len && self.code[self.ptr] == `.` {
			decimal := self.consume_float()

			return Token{TokenType.float, integer + decimal}
		}

		return Token{TokenType.int, integer}
	} else if chr == `.` && self.ptr + 1 < self.code.len && u8(self.code[self.ptr + 1]).is_digit() {
		decimal := self.consume_float().f32().str() // convert '.12' > 0.12 > '0.12'

		return Token{TokenType.float, decimal}
	} else {
		return error("Can't tokenize ${chr}.")
	}
}

fn (mut self Tokenizer) next() ?Token {
	if self.iter_token.kind == TokenType.eof {
		return none
	}

	self.iter_token = self.next_token() or { return none }

	return self.iter_token
}

fn (mut self Tokenizer) consume_int() string {
	start := self.ptr

	for self.ptr < self.code.len && u8(self.code[self.ptr]).is_digit() {
		self.ptr += 1
	}

	return self.code[start..self.ptr].string()
}

fn (mut self Tokenizer) consume_float() string {
	start := self.ptr

	self.ptr += 1

	for self.ptr < self.code.len && u8(self.code[self.ptr]).is_digit() {
		self.ptr += 1
	}

	float_str := if self.ptr - start > 1 {
		self.code[start..self.ptr].string()
	} else {
		'.0'
	}

	return float_str
}
