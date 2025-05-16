module main

struct Token {
	kind TokenKind
}

fn new_token(kind TokenKind) &Token {
	return &Token{ kind }
}
