module main

struct Tokenizer {
	code []rune
mut:
	ptr               int
	beginning_of_line bool
	iter_token        Token
}

fn Tokenizer.new(code string) Tokenizer {
	return Tokenizer{
		code: (code + '\n').runes()
		ptr: 0
		beginning_of_line: true
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

fn (mut self Tokenizer) peek(length int) string {
	end := self.ptr + length

	return if end <= self.code.len {
		self.code[self.ptr..end].string()
	} else {
		''
	}
}

fn (mut self Tokenizer) next_token() !Token {
	chars_as_tokens := {
		`+`: TokenType.plus
		`-`: TokenType.minus
		`*`: TokenType.mul
		`/`: TokenType.div
		`%`: TokenType.mod
		`(`: TokenType.lparen
		`)`: TokenType.rparen
		`=`: TokenType.assign
	}

	for self.ptr < self.code.len && self.code[self.ptr] == ` ` {
		self.ptr += 1
	}

	if self.ptr == self.code.len {
		return Token{TokenType.eof, 'eof'}
	}

	chr := self.code[self.ptr]

	if chr == `\n` {
		self.ptr += 1

		if !self.beginning_of_line {
			self.beginning_of_line = true

			return Token{TokenType.newline, 'newline'}
		} else {
			return self.next_token()
		}
	}

	self.beginning_of_line = false

	if self.peek(2) == '**' {
		self.ptr += 2

		return Token{TokenType.exp, '**'}
	} else if chr in chars_as_tokens {
		self.ptr += 1

		return Token{chars_as_tokens[chr], chr.str()}
	} else if is_legal_name_start_characters(u8(chr)) {
		name := self.consume_name()

		return Token{TokenType.name, name}
	} else if is_digit(u8(chr)) {
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

fn (mut self Tokenizer) consume_name() string {
	start := self.ptr

	self.ptr += 1

	for self.ptr < self.code.len && is_legal_name_characters(u8(self.code[self.ptr])) {
		self.ptr += 1
	}

	return self.code[start..self.ptr].string()
}

fn (mut self Tokenizer) consume_int() string {
	start := self.ptr

	for self.ptr < self.code.len && is_digit(u8(self.code[self.ptr])) {
		self.ptr += 1
	}

	return self.code[start..self.ptr].string()
}

fn (mut self Tokenizer) consume_float() string {
	start := self.ptr

	self.ptr += 1

	for self.ptr < self.code.len && is_digit(u8(self.code[self.ptr])) {
		self.ptr += 1
	}

	float_str := if self.ptr - start > 1 {
		self.code[start..self.ptr].string()
	} else {
		'.0'
	}

	return float_str
}
