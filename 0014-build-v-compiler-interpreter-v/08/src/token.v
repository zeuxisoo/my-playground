module main

enum TokenType {
	int
	float
	plus
	minus
	mul
	div
	mod
	exp
	lparen
	rparen
	newline
	name
	assign
	@if
	colon
	indent
	dedent
	@true
	@false
	not
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

fn is_digit(chr u8) bool {
	return chr.is_digit()
}

fn is_legal_name_characters(chr u8) bool {
	return chr.is_letter() || chr.is_digit() || chr.ascii_str() == '_'
}

fn is_legal_name_start_characters(chr u8) bool {
	return chr.is_letter() || chr.ascii_str() == '_'
}
