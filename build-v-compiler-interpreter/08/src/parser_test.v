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

	assert parser.parse_computation()! == Expr(Constant{3})
}

fn test_parsing_single_float() {
	tokens := [
		Token{TokenType.float, '3.0'},
		Token{TokenType.eof, 'eof'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(Constant{f32(3.0)})
}

fn test_parsing_addition() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '+'
		left: Constant{3}
		right: Constant{5}
	})
}

fn test_parsing_subtraction() {
	tokens := [
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '2'},
		Token{TokenType.eof, 'eof'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_computation()! == Expr(BinOp{
		operator: '-'
		left: Constant{5}
		right: Constant{2}
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
		left: Constant{f32(0.5)}
		right: Constant{5}
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
		left: Constant{f32(5.0)}
		right: Constant{f32(0.2)}
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
			left: Constant{3}
			right: Constant{5}
		}
		right: Constant{f32(0.2)}
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
			left: Constant{3}
			right: Constant{5}
		}
		right: Constant{f32(0.2)}
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
						left: Constant{3}
						right: Constant{5}
					}
					right: Constant{7}
				}
				right: Constant{f32(1.2)}
			}
			right: Constant{f32(2.4)}
		}
		right: Constant{f32(3.6)}
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
		value: Constant{3}
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
		value: Constant{f32(3.0)}
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
						value: Constant{f32(3.5)}
					}
				}
			}
		}
		right: Constant{2}
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
		left: Constant{1}
		right: BinOp{
			operator: '+'
			left: Constant{2}
			right: Constant{3}
		}
	})
}

fn test_parsing_parentheses_around_single_value() {
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
		left: Constant{1}
		right: BinOp{
			operator: '+'
			left: Constant{2}
			right: Constant{3}
		}
	})
}

fn test_parsing_unbalanced_parentheses() {
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
					left: Constant{1}
					right: UnaryOp{
						operator: '-'
						value: BinOp{
							operator: '**'
							left: Constant{2}
							right: UnaryOp{
								operator: '-'
								value: Constant{3}
							}
						}
					}
				}
				right: Constant{5}
			}
			right: Constant{2}
		}
		right: BinOp{
			operator: '**'
			left: Constant{2}
			right: Constant{3}
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
					left: Constant{1}
					right: UnaryOp{
						operator: '-'
						value: Constant{2}
					}
				}
			},
			ExprStatement{
				expr: BinOp{
					operator: '/'
					left: BinOp{
						operator: '**'
						left: Constant{5}
						right: UnaryOp{
							operator: '-'
							value: Constant{3}
						}
					}
					right: Constant{5}
				}
			},
			ExprStatement{
				expr: BinOp{
					operator: '+'
					left: BinOp{
						operator: '*'
						left: Constant{1}
						right: Constant{2}
					}
					right: BinOp{
						operator: '**'
						left: Constant{2}
						right: Constant{3}
					}
				}
			},
		]
	}
}

fn test_parsing_simple_assignment() {
	tokens := [
		Token{TokenType.name, 'a'},
		Token{TokenType.assign, '='},
		Token{TokenType.int, '5'},
		Token{TokenType.newline, 'newline'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_assignment()! == Assignment{
		targets: [
			Variable{'a'},
		]
		value: Constant{5}
	}
}

fn test_parsing_program_with_assignments() {
	code := 'a = 3\nb = 7\nd = 2 ** 2 % 4'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
				]
				value: Constant{3}
			},
			Assignment{
				targets: [
					Variable{'b'},
				]
				value: Constant{7}
			},
			Assignment{
				targets: [
					Variable{'d'},
				]
				value: BinOp{
					operator: '%'
					left: BinOp{
						operator: '**'
						left: Constant{2}
						right: Constant{2}
					}
					right: Constant{4}
				}
			},
		]
	}
}

fn test_parsing_variable_references() {
	code := 'a = b + 3'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
				]
				value: BinOp{
					operator: '+'
					left: Variable{'b'}
					right: Constant{3}
				}
			},
		]
	}
}

fn test_parsing_consecutive_assignments() {
	code := 'a = b = c = 3'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
					Variable{'b'},
					Variable{'c'},
				]
				value: Constant{3}
			},
		]
	}
}

fn test_parsing_conditional() {
	code := 'if 3 ** 4 - 80:\n    a = 3\n    b = 5'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Conditional{
				condition: BinOp{
					operator: '-'
					left: BinOp{
						operator: '**'
						left: Constant{3}
						right: Constant{4}
					}
					right: Constant{80}
				}
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'a'},
							]
							value: Constant{3}
						},
						Assignment{
							targets: [
								Variable{'b'},
							]
							value: Constant{5}
						},
					]
				}
			},
		]
	}
}

fn test_parsing_nested_conditionals() {
	code := 'if 1:\n\ta = 3\n\tb = a\n\tif 2:\n\t\tc = 3'.replace('\t', ' '.repeat(4))

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Conditional{
				condition: Constant{1}
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'a'},
							]
							value: Constant{3}
						},
						Assignment{
							targets: [
								Variable{'b'},
							]
							value: Variable{'a'}
						},
						Conditional{
							condition: Constant{2}
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'c'},
										]
										value: Constant{3}
									},
								]
							}
						},
					]
				}
			},
		]
	}
}

fn test_parsing_booleans() {
	code := 'if true:\n\ta = false\n\tb = true'.replace('\t', ' '.repeat(4))

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			Conditional{
				condition: Constant{true}
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'a'},
							]
							value: Constant{false}
						},
						Assignment{
							targets: [
								Variable{'b'},
							]
							value: Constant{true}
						},
					]
				}
			},
		]
	}
}

fn test_parsing_single_negation() {
	tokens := [
		Token{TokenType.not, 'not'},
		Token{TokenType.@true, 'true'},
		Token{TokenType.newline, 'newline'},
	]

	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse_expr()! == Expr(UnaryOp{
		operator: 'not'
		value: Constant{true}
	})
}

fn test_multiple_negations() {
	code := 'not not not not not a'

	mut tokens := create_tokens(code)
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == Program{
		statements: [
			ExprStatement{
				expr: UnaryOp{
					operator: 'not'
					value: UnaryOp{
						operator: 'not'
						value: UnaryOp{
							operator: 'not'
							value: UnaryOp{
								operator: 'not'
								value: UnaryOp{
									operator: 'not'
									value: Variable{'a'}
								}
							}
						}
					}
				}
			},
		]
	}
}
