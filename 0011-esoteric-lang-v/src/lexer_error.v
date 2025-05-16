module main

struct LexerError {
}

fn new_lexer_error() &LexerError {
	return &LexerError{}
}

fn (le LexerError) unexpected_token(got string, expected string, column int) IError {
	return error('lexer:${column+1}: unexpected token `${got}`, expected `${expected}`')
}

fn (le LexerError) unexpected_token_after(got string, expected string, after string, column int) IError {
	return error('lexer:${column+1}: unexpceted token `${got}`, expected `${expected}` after `${after}`')
}

fn (le LexerError) unknown_token(got string, column int) IError {
	return error('lexer:${column+1}: unknown token `${got}`')
}

fn (le LexerError) out_of_content_range(got int, expected int, column int) IError {
	return error('lexer:${column+1}: selected out of content range `${got}`, the content range `${expected}`')
}
