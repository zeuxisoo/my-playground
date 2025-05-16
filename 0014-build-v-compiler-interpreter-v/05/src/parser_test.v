module main

fn create_tokens(code string) []Token {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := []Token{}

	for token in tokenizer {
		tokens << token
	}

	return tokens
}

fn create_parser_from_tokens(tokens []Token) Parser {
	return Parser.new(tokens)
}

fn test_parsing_single_integer() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(Number(Int{3}))
}

fn test_parsing_single_float() {
	tokens := [
		Token{TokenType.float, '3.0'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(Number(Float{3.0}))
}

fn test_parse_addition() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: Number(Int{3})
		right: Number(Int{5})
	})
}

fn test_parse_subtraction() {
	tokens := [
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: Number(Int{5})
		right: Number(Int{2})
	})
}

fn test_parsing_addition_with_floats() {
	tokens := [
		Token{TokenType.float, '0.5'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: Number(Float{0.5})
		right: Number(Int{5})
	})
}

fn test_parsing_subtraction_with_floats() {
	tokens := [
		Token{TokenType.float, '5.0'},
		Token{TokenType.minus, '-'},
		Token{TokenType.float, '0.2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: Number(Float{5.0})
		right: Number(Float{0.2})
	})
}

fn test_parsing_addition_then_subtraction() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.float, '0.2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: BinOp{
			operator: '+'
			left: Number(Int{3})
			right: Number(Int{5})
		}
		right: Number(Float{0.2})
	})
}

fn test_parsing_subtraction_then_addition() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '5'},
		Token{TokenType.plus, '+'},
		Token{TokenType.float, '0.2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: BinOp{
			operator: '-'
			left: Number(Int{3})
			right: Number(Int{5})
		}
		right: Number(Float{0.2})
	})
}

fn test_parsing_many_additions_and_subtractions() {
	// 3 + 5 - 7 + 1.2 + 2.4 - 3.6
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '7'},
		Token{TokenType.plus, '+'},
		Token{TokenType.float, '1.2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.float, '2.4'},
		Token{TokenType.minus, '-'},
		Token{TokenType.float, '3.6'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: BinOp{
			operator: '+'
			left: BinOp{
				operator: '+'
				left: BinOp{
					operator: '-'
					left: BinOp{
						operator: '+'
						left: Number(Int{3})
						right: Number(Int{5})
					}
					right: Number(Int{7})
				}
				right: Number(Float{1.2})
			}
			right: Number(Float{2.4})
		}
		right: Number(Float{3.6})
	})
}

fn test_parsing_unary_minus() {
	tokens := [
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '3'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(UnaryOp{
		operator: '-'
		value: Number(Int{3})
	})
}

fn test_parsing_unary_plus() {
	tokens := [
		Token{TokenType.plus, '+'},
		Token{TokenType.float, '3.0'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(UnaryOp{
		operator: '+'
		value: Number(Float{3.0})
	})
}

fn test_parsing_unary_operators() {
	// --++3.5 - 2
	tokens := [
		Token{TokenType.minus, '-'},
		Token{TokenType.minus, '-'},
		Token{TokenType.plus, '+'},
		Token{TokenType.plus, '+'},
		Token{TokenType.float, '3.5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: UnaryOp{
			operator: '-'
			value: UnaryOp{
				operator: '-'
				value: UnaryOp{
					operator: '+'
					value: UnaryOp{
						operator: '+'
						value: Number(Float{3.5})
					}
				}
			}
		}
		right: Number(Int{2})
	})
}

fn test_parsing_parentheses() {
	// 1 + ( 2 + 3 )
	tokens := [
		Token{TokenType.int, '1'},
		Token{TokenType.plus, '+'},
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '3'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: Number(Int{1})
		right: BinOp{
			operator: '+'
			left: Number(Int{2})
			right: Number(Int{3})
		}
	})
}

fn test_parsing_parentheses_around_single_number() {
	// ( ( ( 1 ) ) ) + ( 2 + ( 3 ) )
	tokens := [
		Token{TokenType.lparen, '('},
		Token{TokenType.lparen, '('},
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '1'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.plus, '+'},
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '3'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: Number(Int{1})
		right: BinOp{
			operator: '+'
			left: Number(Int{2})
			right: Number(Int{3})
		}
	})
}

fn test_unbalanced_parentheses() {
	codes := [
		'(1',
		'()',
		') 1 + 2',
		'1 + 2)',
		'1 (+) 2',
		'1 + )2(',
	]

	for code in codes {
		mut tokens := create_tokens(code)
		mut parser := create_parser_from_tokens(tokens)

		parser.parse_computation() or { assert true }
	}
}

fn test_parsing_more_operators() {
	// "1 % -2 ** -3 / 5 * 2 + 2 ** 3"
	tokens := [
		Token{TokenType.int, '1'},
		Token{TokenType.mod, '%'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '2'},
		Token{TokenType.exp, '**'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '3'},
		Token{TokenType.div, '/'},
		Token{TokenType.int, '5'},
		Token{TokenType.mul, '*'},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '2'},
		Token{TokenType.exp, '**'},
		Token{TokenType.int, '3'},
		Token{TokenType.eof, 'eof'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: BinOp{
			operator: '*'
			left: BinOp{
				operator: '/'
				left: BinOp{
					operator: '%'
					left: Number(Int{1})
					right: UnaryOp{
						operator: '-'
						value: BinOp{
							operator: '**'
							left: Number(Int{2})
							right: UnaryOp{
								operator: '-'
								value: Number(Int{3})
							}
						}
					}
				}
				right: Number(Int{5})
			}
			right: Number(Int{2})
		}
		right: BinOp{
			operator: '**'
			left: Number(Int{2})
			right: Number(Int{3})
		}
	})
}

fn test_parsing_multiple_statements() {
	code := '1 % -2\n5 ** -3 / 5\n1 * 2 + 2 ** 3\n'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			ExprStatement{
				expr: BinOp{
					operator: '%'
					left: Number(Int{1})
					right: UnaryOp{
						operator: '-'
						value: Number(Int{2})
					}
				}
			},
			ExprStatement{
				expr: BinOp{
					operator: '/'
					left: BinOp{
						operator: '**'
						left: Number(Int{5})
						right: UnaryOp{
							operator: '-'
							value: Number(Int{3})
						}
					}
					right: Number(Int{5})
				}
			},
			ExprStatement{
				expr: BinOp{
					operator: '+'
					left: BinOp{
						operator: '*'
						left: Number(Int{1})
						right: Number(Int{2})
					}
					right: BinOp{
						operator: '**'
						left: Number(Int{2})
						right: Number(Int{3})
					}
				}
			},
		]
	}
}
