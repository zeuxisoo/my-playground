module main

enum TokenType {
	int
	plus
	minus
	eof
}

struct Token {
pub:
	kind  TokenType
	value string
}
