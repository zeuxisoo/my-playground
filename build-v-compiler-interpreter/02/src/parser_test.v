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

fn test_parsing_addition_with_floats() {
	tokens := [
		Token{TokenType.float, '0.5'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == BinOp{
		operator: '+'
		left: Float{0.5}
		right: Int{5}
	}
}

fn test_parsing_subtraction_with_floats() {
	tokens := [
		Token{TokenType.float, '5.0'},
		Token{TokenType.minus, '-'},
		Token{TokenType.float, '0.2'},
		Token{TokenType.eof, 'eof'},
	]
	mut parser := create_parser_from_tokens(tokens)

	assert parser.parse()! == BinOp{
		operator: '-'
		left: Float{5.0}
		right: Float{0.2}
	}
}
