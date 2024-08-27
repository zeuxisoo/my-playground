module main

enum TokenKind {
	str
	num
	kw
	var
	punc
	op
}

struct TokenValue {
	kind  TokenKind
	value string
}

struct Token {
mut:
	input    Input
	current  ?TokenValue
	keywords string
}

fn Token.new(input Input) Token {
	return Token{
		input:    input
		current:  none
		keywords: ' let if then else lambda λ true false '
	}
}

pub fn (mut t Token) next() ?TokenValue {
	tok := t.current

	t.current = none

	if tok != none {
		return tok
	} else {
		return t.read_next()
	}
}

pub fn (mut t Token) peek() ?TokenValue {
	if t.current != none {
		return t.current
	} else {
		t.current = t.read_next()

		return t.current
	}
}

pub fn (mut t Token) eof() bool {
	return t.peek() == none
}

pub fn (t Token) croak(msg string) IError {
	return t.input.croak(msg)
}

//
fn (mut t Token) read_next() ?TokenValue {
	t.read_while(t.is_whitespace)

	if t.input.eof() {
		return none
	}

	ch := t.input.peek()?

	if ch == `#` {
		t.skip_comment()
		return t.read_next()
	}

	if ch == `"` {
		return t.read_string()
	}

	if t.is_digit(ch) {
		return t.read_number()
	}

	if t.is_id_start(ch) {
		return t.read_ident()
	}

	if t.is_punc(ch) {
		return TokenValue{
			kind:  .punc
			value: t.input.next().str()
		}
	}

	if t.is_op_char(ch) {
		return TokenValue{
			kind:  .op
			value: t.read_while(t.is_op_char)?
		}
	}

	t.input.croak('Can\'t handle character: ${ch}')

	return none
}

fn (mut t Token) read_while(predicate fn (rune) bool) ?string {
	mut str := []rune{}

	for !t.input.eof() {
		ch := t.input.peek() or { break }

		if !predicate(ch) {
			break
		}

		str << t.input.next()
	}

	return str.string()
}

fn (mut t Token) read_string() TokenValue {
	return TokenValue{
		kind:  .str
		value: t.read_escaped(`"`)
	}
}

fn (mut t Token) read_number() ?TokenValue {
	mut has_dot := false

	number := t.read_while(fn [mut t, mut has_dot] (ch rune) bool {
		if ch == `.` {
			if has_dot {
				return false
			}

			has_dot = true

			return true
		}

		return t.is_digit(ch)
	})?

	return TokenValue{
		kind:  .num
		value: number
	}
}

fn (mut t Token) read_ident() ?TokenValue {
	id := t.read_while(t.is_id)?

	return TokenValue{
		kind: if t.is_keyword(id) {
			.kw
		} else {
			.var
		}
		value: id
	}
}

fn (mut t Token) read_escaped(end rune) string {
	mut escaped := false
	mut str := []rune{}

	t.input.next()

	for !t.input.eof() {
		ch := t.input.next()

		if escaped {
			str << ch
			escaped = false
		} else if ch == `\\` { // or: rune(92)
			escaped = true
		} else if ch == end {
			break
		} else {
			str << ch
		}
	}

	return str.string()
}

//
@[inline]
fn (mut t Token) skip_comment() {
	t.read_while(fn (ch rune) bool {
		return ch != `\n`
	})
	t.input.next()
}

//
@[inline]
fn (t Token) is_whitespace(ch rune) bool {
	return ch in [` `, `\t`, `\n`]
}

fn (t Token) is_digit(ch rune) bool {
	ch_ := int(ch - `0`) // cast to index from (ascii code: dec - 48)

	return ch_ >= 0 && ch_ <= 9
}

fn (t Token) is_id_start(ch rune) bool {
	return (ch >= 97 && ch <= 122) || ch == `λ` || ch == `_`
}

@[inline]
fn (t Token) is_id(ch rune) bool {
	return t.is_id_start(ch) || ch in '?!-<>=0123456789'.runes()
}

@[inline]
fn (t Token) is_keyword(x string) bool {
	return t.keywords.index(' ${x} ') != none
}

@[inline]
fn (t Token) is_punc(ch rune) bool {
	return ch in ',;(){}[]'.runes()
}

fn (t Token) is_op_char(ch rune) bool {
	return ch in '+-*/%=&|<>!'.runes()
}
