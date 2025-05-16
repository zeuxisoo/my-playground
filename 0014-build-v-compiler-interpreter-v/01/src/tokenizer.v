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
	self.ptr += 1

	if chr == `+` {
		return Token{TokenType.plus, chr.str()}
	} else if chr == `-` {
		return Token{TokenType.minus, chr.str()}
	} else if u8(chr).is_digit() {
		return Token{TokenType.int, chr.str()}
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
