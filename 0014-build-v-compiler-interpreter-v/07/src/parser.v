module main

struct Parser {
	tokens []Token
mut:
	next_token_index int
}

// program := statement* EOF
//
// statement := expr_statement | assignment | conditional
//
// assignment := ( NAME ASSIGN )+ computation NEWLINE
// expr_statement := computation NEWLINE
// conditional := IF computation COLON NEWLINE body
//
// body := INDENT statement+ DEDENT
//
// computation := term ( (PLUS | MINUS) term )*
// term := unary ( (MUL | DIV | MOD) unary )*
// unary := PLUS unary | MINUS unary | exponentiation
// exponentiation := atom EXP unary | atom
// atom := LPAREN computation RPAREN | value
// value := NAME | INT | FLOAT
fn Parser.new(tokens []Token) Parser {
	return Parser{
		tokens: tokens
		next_token_index: 0
	}
}

// program := computation EOF
fn (mut self Parser) parse() !Program {
	mut program := Program{}

	for self.peek(0)! != TokenType.eof {
		program.statements << self.parse_statement()!
	}

	self.eat(TokenType.eof)!

	return program
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

// statement := expr_statement | assignment | conditional
fn (mut self Parser) parse_statement() !Statement {
	// dump(self.peek(1))
	if self.peek(1)! == TokenType.assign {
		return self.parse_assignment()!
	} else if self.peek(0)! == TokenType.@if {
		return self.parse_conditional()!
	} else {
		return self.parse_expr_statement()!
	}
}

// assignment := ( NAME ASSIGN )+ computation NEWLINE
fn (mut self Parser) parse_assignment() !Assignment {
	mut first := true
	mut targets := []Variable{}

	for first || self.peek(1)! == TokenType.assign {
		first = false

		name_token := self.eat(TokenType.name)!

		self.eat(TokenType.assign)!

		targets << Variable{
			name: name_token.value
		}
	}

	value := self.parse_computation()!

	self.eat(TokenType.newline)!

	return Assignment{
		targets: targets
		value: value
	}
}

// conditional := IF computation COLON NEWLINE body
fn (mut self Parser) parse_conditional() !Conditional {
	self.eat(TokenType.@if)!

	condition := self.parse_computation()!

	self.eat(TokenType.colon)!
	self.eat(TokenType.newline)!

	body := self.parse_body()!

	return Conditional{
		condition: condition
		body: body
	}
}

// expr_statement := computation NEWLINE
fn (mut self Parser) parse_expr_statement() !ExprStatement {
	expr := ExprStatement{
		expr: self.parse_computation()!
	}

	self.eat(TokenType.newline)!

	return expr
}

// body := INDENT statement+ DEDENT
fn (mut self Parser) parse_body() !Body {
	self.eat(TokenType.indent)!

	mut body := Body{}

	for self.peek(0)! != TokenType.dedent {
		body.statements << self.parse_statement()!
	}

	self.eat(TokenType.dedent)!

	return body
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

// value := NAME | INT | FLOAT
fn (mut self Parser) parse_value() !Value {
	if self.peek(0)! == TokenType.name {
		token := self.eat(TokenType.name)!
		token_value := token.value

		return Variable{token_value}
	} else if self.peek(0)! == TokenType.int {
		token := self.eat(TokenType.int)!
		token_value := token.value.int()

		return Int{token_value}
	} else {
		token := self.eat(TokenType.float)!
		token_value := token.value.f32()

		return Float{token_value}
	}
}

// atom := LPAREN computation RPAREN | value
fn (mut self Parser) parse_atom() !Expr {
	return if self.peek(0)! == TokenType.lparen {
		self.eat(TokenType.lparen)!

		result := self.parse_computation()!

		self.eat(TokenType.rparen)!

		result
	} else {
		self.parse_value()!
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
