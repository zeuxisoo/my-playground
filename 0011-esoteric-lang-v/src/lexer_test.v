module main

fn test_tokenise() {
	lexer := new_lexer()
	tokens := lexer.tokenise('~> <~ + - $ [ ] look')!

	assert tokens == expected_tokens(
		.right_tilde_arrow,
		.left_tilde_arrow,
		.plus,
		.minus,
		.dollar,
		.left_brackets,
		.right_brackets,
		.look,
	)
}

fn test_tokenise_without_space() {
	lexer := new_lexer()
	tokens := lexer.tokenise('~><~+-$[look]')!

	assert tokens == expected_tokens(
		.right_tilde_arrow,
		.left_tilde_arrow,
		.plus,
		.minus,
		.dollar,
		.left_brackets,
		.look,
		.right_brackets,
	)
}

fn test_tokenise_unexpected_token() {
	for value in ['l ~>', 'leds'] {
		new_lexer().tokenise(value) or {
			assert err == error('lexer:1: unexpected token `${value}`, expected `look`')
		}
	}
}

fn test_tokenise_unexpected_after_right_tilde_arrow() {
	new_lexer().tokenise('~>') or {
		assert err == error('lexer:2: unexpceted token `~`, expected `>` after `=`')
	}
}

fn test_tokenise_unexpected_after_left_tilde_arrow() {
	new_lexer().tokenise('<~') or {
		assert err == error('lexer:2: unexpceted token `~`, expected `=` after `<`')
	}
}

fn test_tokenise_unknown() {
	new_lexer().tokenise('?') or {
		assert err == error('lexer:1: unknown token `?`')
	}
}

fn test_tokenise_out_of_content_range() {
	new_lexer().tokenise('l') or {
		assert err == error('lexer:1: selected out of content range `4`, the content range `1`')
	}
}

//
fn expected_tokens(kinds ...TokenKind) []Token {
	mut tokens := []Token{}

	for kind in kinds {
		tokens << new_token(kind)
	}

	return tokens
}
