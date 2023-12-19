module main

enum TokenType {
	int
	float
	plus
	minus
	eof
}

fn (self TokenType) str_full() string {
	return '${typeof(self).name}.${self.str()}'
}

struct Token {
pub:
	kind  TokenType
	value string
}

fn (self Token) str() string {
	return 'Token(${self.kind.str_full()}, ${self.value})'
}
