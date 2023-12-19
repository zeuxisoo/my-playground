module main

struct Parser {
	tokens []Token
mut:
	next_token_index int
}

// program := computation
// computation := number ( (PLUS | MINUS) number )*
// number := INT | FLOAT
fn Parser.new(tokens []Token) Parser {
	return Parser{
		tokens: tokens
		next_token_index: 0
	}
}

// program := computation EOF
fn (mut self Parser) parse() !Expr {
	computation := self.parse_computation()!

	self.eat(TokenType.eof)!

	return computation
}

fn (mut self Parser) eat(expected_token_type TokenType) !Token {
	next_token := self.tokens[self.next_token_index]

	self.next_token_index += 1

	if next_token.kind != expected_token_type {
		return error('Expected ${expected_token_type}, ate ${next_token.kind}.')
	}

	return next_token
}

fn (self Parser) peek(skip int) !TokenType {
	peek_at := self.next_token_index + skip

	if peek_at < self.tokens.len {
		return self.tokens[peek_at].kind
	}

	return error('Out of content for parsing')
}

// number := INT | FLOAT
fn (mut self Parser) parse_number() !Expr {
	if self.peek(0)! == TokenType.int {
		token := self.eat(TokenType.int)!
		token_value := token.value.int()

		return Number(Int{token_value})
	} else {
		token := self.eat(TokenType.float)!
		token_value := token.value.f32()

		return Number(Float{token_value})
	}
}

// computation := number (PLUS | MINUS) number
fn (mut self Parser) parse_computation() !Expr {
	mut result := self.parse_number()!

	for {
		next_token_type := self.peek(0)!

		if next_token_type !in [TokenType.plus, TokenType.minus] {
			break
		}

		operator := if next_token_type == TokenType.plus {
			'+'
		} else {
			'-'
		}

		self.eat(next_token_type)!

		right := self.parse_number()!

		result = BinOp{
			operator: operator
			left: result
			right: right
		}
	}

	return result

	// mut left_operator := self.parse_number()!

	// mut operator := ''
	// if self.peek(0)! == TokenType.plus {
	// 	operator = '+'
	// 	self.eat(TokenType.plus)!
	// } else {
	// 	operator = '-'
	// 	self.eat(TokenType.minus)!
	// }

	// mut right_operator := self.parse_number()!

	// return BinOp{
	// 	operator: operator
	// 	left: left_operator
	// 	right: right_operator
	// }
}
