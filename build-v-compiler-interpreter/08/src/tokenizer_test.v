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

fn test_tokenizer__tokenize() {
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer__next_token_ordered() {
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_token_random() {
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_token_additions_and_subtractions_with_whitespace() {
	code := '1+       2   +3+4-5  -   6 + 7  - 8        '
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_token_error() {
	code := '$'

	create_token(code) or { assert err.msg() == "Can't tokenize $." }
}

fn test_tokenizer_next_token_plus() {
	code := '+'
	token := create_token(code)!

	assert token == Token{TokenType.plus, '+'}
}

fn test_tokenizer_next_token_minus() {
	code := '-'
	token := create_token(code)!

	assert token == Token{TokenType.minus, '-'}
}

fn test_tokenizer_next_token_integer() {
	code := '3'
	token := create_token(code)!

	assert token == Token{TokenType.int, '3'}
}

fn test_tokenizer_next_iterator_ordered() {
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_iterator_random() {
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
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_iterator_addition() {
	code := '3 + 5'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '5'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_next_iterator_subtraction() {
	code := '3 - 6'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.int, '3'},
		Token{TokenType.minus, '-'},
		Token{TokenType.int, '6'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_long_integers() {
	code_results := [
		CodeResult[Token]{'61      ', Token{TokenType.int, '61'}},
		CodeResult[Token]{'72345    ', Token{TokenType.int, '72345'}},
		CodeResult[Token]{'9142351643', Token{TokenType.int, '9142351643'}},
		CodeResult[Token]{'642357413455672', Token{TokenType.int, '642357413455672'}},
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

fn test_tokenizer_recognises_each_token() {
	code_results := [
		CodeResult[Token]{'*', Token{TokenType.mul, '*'}},
		CodeResult[Token]{'/', Token{TokenType.div, '/'}},
		CodeResult[Token]{'%', Token{TokenType.mod, '%'}},
		CodeResult[Token]{'**', Token{TokenType.exp, '**'}},
		CodeResult[Token]{'(', Token{TokenType.lparen, '('}},
		CodeResult[Token]{')', Token{TokenType.rparen, ')'}},
		CodeResult[Token]{'a', Token{TokenType.name, 'a'}},
		CodeResult[Token]{'abc123_', Token{TokenType.name, 'abc123_'}},
		CodeResult[Token]{'_123', Token{TokenType.name, '_123'}},
		CodeResult[Token]{'_', Token{TokenType.name, '_'}},
		CodeResult[Token]{'a_2_c_3___', Token{TokenType.name, 'a_2_c_3___'}},
		CodeResult[Token]{'=', Token{TokenType.assign, '='}},
		CodeResult[Token]{'if', Token{TokenType.@if, 'if'}},
		CodeResult[Token]{':', Token{TokenType.colon, ':'}},
		CodeResult[Token]{'true', Token{TokenType.@true, 'true'}},
		CodeResult[Token]{'false', Token{TokenType.@false, 'false'}},
		CodeResult[Token]{'not', Token{TokenType.not, 'not'}},
	]

	for code_result in code_results {
		token := create_token(code_result.code)!

		assert token == code_result.expected
	}
}

fn test_tokenizer_parentheses_in_code() {
	code := '( 1 ( 2 ) 3 ( ) 4'
	tokens := create_tokens_iter(code)

	assert tokens == [
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '1'},
		Token{TokenType.lparen, '('},
		Token{TokenType.int, '2'},
		Token{TokenType.rparen, ')'},
		Token{TokenType.int, '3'},
		Token{TokenType.lparen, '('},
		Token{TokenType.rparen, ')'},
		Token{TokenType.int, '4'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_distinguishes_mul_and_exp() {
	code := '1 * 2 ** 3 * 4 ** 5'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.mul, '*'},
		Token{TokenType.int, '2'},
		Token{TokenType.exp, '**'},
		Token{TokenType.int, '3'},
		Token{TokenType.mul, '*'},
		Token{TokenType.int, '4'},
		Token{TokenType.exp, '**'},
		Token{TokenType.int, '5'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_ignores_extra_newlines() {
	codes := [
		'\n\n\n1 + 2\n3 + 4\n', // Extras at the beginning.
		'1 + 2\n\n\n3 + 4\n', // Extras in the middle.
		'1 + 2\n3 + 4\n\n\n', // Extras at the end.
		'\n\n\n1 + 2\n\n\n3 + 4\n\n\n', // Extras everywhere.
	]

	for code in codes {
		tokens := create_tokens_loop(code)!

		assert tokens == [
			Token{TokenType.int, '1'},
			Token{TokenType.plus, '+'},
			Token{TokenType.int, '2'},
			Token{TokenType.newline, 'newline'},
			Token{TokenType.int, '3'},
			Token{TokenType.plus, '+'},
			Token{TokenType.int, '4'},
			Token{TokenType.newline, 'newline'},
			Token{TokenType.eof, 'eof'},
		]
	}
}

fn test_tokenizer_names() {
	code := 'a + 3 - b c12 __d'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.name, 'a'},
		Token{TokenType.plus, '+'},
		Token{TokenType.int, '3'},
		Token{TokenType.minus, '-'},
		Token{TokenType.name, 'b'},
		Token{TokenType.name, 'c12'},
		Token{TokenType.name, '__d'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_assignment_operator() {
	code := 'a = 3 = = 5'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.name, 'a'},
		Token{TokenType.assign, '='},
		Token{TokenType.int, '3'},
		Token{TokenType.assign, '='},
		Token{TokenType.assign, '='},
		Token{TokenType.int, '5'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_indentation_empty_lines() {
	mut code := ''
	code += '1\n'
	code += '        1\n' // 2 indents
	code += '        \n'
	code += '        \n'
	code += '            1\n' // 1 indent
	code += '        \n'
	code += '            \n'
	code += '    \n'
	code += '    1\n' // 2 dedents
	code += '        \n'
	code += '            \n'
	code += '                    \n'
	code += '1\n' // 1 dedent
	code += '    \n'
	code += '            \n'
	code += '\n'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.int, '1'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.indent, 'indent'},
		Token{TokenType.indent, 'indent'},
		Token{TokenType.int, '1'}, // 2 idents
		Token{TokenType.newline, 'newline'},
		Token{TokenType.indent, 'indent'},
		Token{TokenType.int, '1'}, // 1 indent
		Token{TokenType.newline, 'newline'},
		Token{TokenType.dedent, 'dedent'},
		Token{TokenType.dedent, 'dedent'},
		Token{TokenType.int, '1'}, // 2 dedents
		Token{TokenType.newline, 'newline'},
		Token{TokenType.dedent, 'dedent'},
		Token{TokenType.int, '1'}, // 1 dedent
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}

fn test_tokenizer_boolean_values() {
	code := 'a = true\nb=false'
	tokens := create_tokens_loop(code)!

	assert tokens == [
		Token{TokenType.name, 'a'},
		Token{TokenType.assign, '='},
		Token{TokenType.@true, 'true'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.name, 'b'},
		Token{TokenType.assign, '='},
		Token{TokenType.@false, 'false'},
		Token{TokenType.newline, 'newline'},
		Token{TokenType.eof, 'eof'},
	]
}
