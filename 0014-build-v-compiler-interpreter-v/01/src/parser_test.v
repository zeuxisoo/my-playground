module main

fn create_tokens(code string) []Token {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := []Token{}

	for token in tokenizer {
		tokens << token
	}

	return tokens
}

fn create_parser_from_string(code string) Parser {
	tokens := create_tokens(code)

	return Parser.new(tokens)
}

fn create_parser_from_tokens(tokens []Token) Parser {
	return Parser.new(tokens)
}

fn test_parse_plus() {
	code := '3 + 5'

	mut parser := create_parser_from_string(code)

	assert parser.parse()! == BinOp{
		operator: '+'
		left: Int{3}
		right: Int{5}
	}
}

fn test_parse_missing_left_int() {
	code := ' + 5'

	mut parser := create_parser_from_string(code)

	parser.parse() or { assert err.msg() == 'Expected int, ate plus.' }
}

fn test_parse_missing_plus() {
	code := '3 3'

	mut parser := create_parser_from_string(code)

	parser.parse() or { assert err.msg() == 'Expected minus, ate int.' }
}

fn test_parse_missing_end_of_file() {
	code := '3 + 5 - 2'

	mut parser := create_parser_from_string(code)

	parser.parse() or { assert err.msg() == 'Expected eof, ate minus.' }
}

fn test_parse_addition() {
	tokens := [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == BinOp{
		operator: '+'
		left: Int{3}
		right: Int{5}
	}
}

fn test_parse_subtraction() {
	tokens := [
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == BinOp{
		operator: '-'
		left: Int{5}
		right: Int{2}
	}
}
