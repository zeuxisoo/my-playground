module main

fn create_tokens_loop(code string) ![]Token {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := []Token{}

	for {
		token := tokenizer.next_token()!

		tokens << token

		if token.kind == TokenType.eof {
			break
		}
	}

	return tokens
}

fn create_tokens_iter(code string) []Token {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := []Token{}

	for token in tokenizer {
		tokens << token
	}

	return tokens
}

fn create_token(code string) !Token {
	mut tokenizer := Tokenizer.new(code)

	return tokenizer.next_token()!
}

fn test_tokenize() {
	code := '1 + 2 - 3 + 4'
	mut tokenizer := Tokenizer.new(code)
	mut tokens := tokenizer.tokenize()!

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '2'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '4'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_token_ordered() {
	code := '1 + 2 + 3 + 4 - 5 - 6 + 7 - 8'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '4'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '6'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '7'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '8'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_token_random() {
	code := '3 3 3 + 5 5 5 - - -'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.int, '3'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.int, '5'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.minus, '-'},
		Token{TokenType.minus, '-'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_token_additions_and_subtractions_with_whitespace() {
	code := '     1+       2   +3+4-5  -   6 + 7  - 8        '
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '4'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '6'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '7'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '8'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_token_error() {
	code := '$'

	create_token(code) or { assert err.msg() == "Can't tokenize $." }
}

fn test_next_token_plus() {
	code := '+'
	token := create_token(code)!

	assert token == Token{TokenType.plus, '+'}
}

fn test_next_token_minus() {
	code := '-'
	token := create_token(code)!

	assert token == Token{TokenType.minus, '-'}
}

fn test_next_token_integer() {
	code := '3'
	token := create_token(code)!

	assert token == Token{TokenType.int, '3'}
}

fn test_next_iterator_ordered() {
	code := '1 + 2 + 3 + 4 - 5 - 6 + 7 - 8'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '2'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '4'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '6'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '7'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '8'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_iterator_random() {
	code := '3 3 3 + 5 5 5 - - -'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.int, '3'},
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.int, '5'},
		Token{TokenType.int, '5'},
		Token{TokenType.minus, '-'},
		Token{TokenType.minus, '-'},
		Token{TokenType.minus, '-'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_iterator_addition() {
	code := '3 + 5'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_next_iterator_subtraction() {
	code := '3 - 6'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '6'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_long_integers() {
	code_results := [
		CodeResult[Token]{' 61      ', Token{TokenType.int, '61'}},
		CodeResult[Token]{'    72345    ', Token{TokenType.int, '72345'}},
		CodeResult[Token]{'9142351643', Token{TokenType.int, '9142351643'}},
		CodeResult[Token]{'     642357413455672', Token{TokenType.int, '642357413455672'}},
	]

	for code_result in code_results {
		token := create_token(code_result.code)!

		assert token == code_result.expected
	}
}

fn test_tokenizer_floats() {
	code_results := [
		CodeResult[Token]{'1.2', Token{TokenType.float, '1.2'}},
		CodeResult[Token]{'.12', Token{TokenType.float, '0.12'}},
		CodeResult[Token]{'73.', Token{TokenType.float, '73.0'}},
		CodeResult[Token]{'0.005', Token{TokenType.float, '0.005'}},
		CodeResult[Token]{'123.456', Token{TokenType.float, '123.456'}},
	]

	for code_result in code_results {
		token := create_token(code_result.code)!

		assert token == code_result.expected
	}
}
