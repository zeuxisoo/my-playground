module main

struct Parser {
	tokens []Token
mut:
	next_token_index int
}

fn Parser.new(tokens []Token) Parser {
	return Parser{
		tokens: tokens
		next_token_index: 0
	}
}

fn (mut self Parser) parse() !BinOp {
	mut left_operator := self.eat(TokenType.int)!
	mut operator := ''

	if self.peek(0)! == TokenType.plus {
		operator = '+'
		self.eat(TokenType.plus)!
	} else {
		operator = '-'
		self.eat(TokenType.minus)!
	}

	mut right_operator := self.eat(TokenType.int)!

	self.eat(TokenType.eof)!

	return BinOp{
		operator: operator
		left: Int{left_operator.value.int()}
		right: Int{right_operator.value.int()}
	}
}

fn (mut self Parser) eat(expected_token_type TokenType) !Token {
	next_token := self.tokens[self.next_token_index]

	self.next_token_index += 1

	if next_token.kind != expected_token_type {
		return error('Expected ${expected_token_type}, ate ${next_token.kind}.')
	}

	return next_token
}

fn (self Parser) peek(skip int) ?TokenType {
	peek_at := self.next_token_index + skip

	if peek_at < self.tokens.len {
		return self.tokens[peek_at].kind
	}

	return none
}
