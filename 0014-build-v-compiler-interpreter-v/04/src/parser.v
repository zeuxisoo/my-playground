module main

struct Parser {
	tokens []Token
mut:
	next_token_index int
}

// program := computation
// computation := term ( (PLUS | MINUS) term )*
// term := unary ( (MUL | DIV | MOD) unary )*
// unary := PLUS unary | MINUS unary | exponentiation
// exponentiation := atom EXP unary | atom
// atom := LPAREN computation RPAREN | number
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

// computation := term ( (PLUS | MINUS) term )*
fn (mut self Parser) parse_computation() !Expr {
	mut result := self.parse_term()!

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

		right := self.parse_term()!

		result = BinOp{
			operator: operator
			left: result
			right: right
		}
	}

	return result
}

// atom := LPAREN computation RPAREN | number
fn (mut self Parser) parse_atom() !Expr {
	return if self.peek(0)! == TokenType.lparen {
		self.eat(TokenType.lparen)!

		result := self.parse_computation()!

		self.eat(TokenType.rparen)!

		result
	} else {
		self.parse_number()!
	}
}

// exponentiation := atom EXP unary | atom
fn (mut self Parser) parse_exponentiation() !Expr {
	mut result := self.parse_atom()!

	if self.peek(0)! == TokenType.exp {
		self.eat(TokenType.exp)!

		result = BinOp{
			operator: '**'
			left: result
			right: self.parse_unary()!
		}
	}

	return result
}

// unary := PLUS unary | MINUS unary | exponentiation
fn (mut self Parser) parse_unary() !Expr {
	next_token_type := self.peek(0)!

	if next_token_type in [TokenType.plus, TokenType.minus] {
		operator := if next_token_type == TokenType.plus {
			'+'
		} else {
			'-'
		}

		self.eat(next_token_type)!

		value := self.parse_unary()!

		return UnaryOp{
			operator: operator
			value: value
		}
	} else {
		return self.parse_exponentiation()!
	}
}

// term := unary ( (MUL | DIV | MOD) unary )*
fn (mut self Parser) parse_term() !Expr {
	mut result := self.parse_unary()!

	types_to_operators := {
		TokenType.mul: '*'
		TokenType.div: '/'
		TokenType.mod: '%'
	}

	for {
		next_token_type := self.peek(0)!

		if next_token_type !in types_to_operators {
			break
		}

		operator := types_to_operators[next_token_type]

		self.eat(next_token_type)!

		right := self.parse_unary()!

		result = BinOp{
			operator: operator
			left: result
			right: right
		}
	}

	return result
}
