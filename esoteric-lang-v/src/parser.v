module main

struct Parser {
mut:
	tokens        []Token
	current_token Token
	next_token    Token
	position      int
}

fn new_parser() &Parser {
	return &Parser{
		position: 0
	}
}

fn (mut p Parser) parse(tokens []Token) !&Node {
	if tokens.len <= 0 {
		return new_program([])
	}

	p.tokens = tokens
	p.current_token = tokens[p.position]

	if p.position + 1 < tokens.len {
		p.next_token = tokens[p.position + 1]
	}

	mut nodes := []&Node{}

	for p.position < tokens.len {
		nodes << p.node() or { return err }
	}

	return new_program(nodes)
}

fn (mut p Parser) node() !&Node {
	match p.current_token.kind {
		.right_tilde_arrow {
			p.next()
			return new_move_right()
		}
		.left_tilde_arrow {
			p.next()
			return new_move_left()
		}
		.plus {
			p.next()
			return new_increment()
		}
		.minus {
			p.next()
			return new_decrement()
		}
		.look {
			p.next()
			return new_look()
		}
		.dollar {
			p.next()
			return new_read_byte()
		}
		.left_brackets {
			p.next()

			mut nodes := []&Node{}

			for p.current_token.kind != .right_brackets && p.position + 1 < p.tokens.len {
				nodes << p.node() or { return err }
			}

			p.expect_token(.right_brackets) or { return err }

			return new_while(nodes)
		}
		else {
			panic('parser: unexpected token ${p.current_token}')
		}
	}
}

fn (mut p Parser) next() {
	p.position = p.position + 1
	p.current_token = p.next_token

	if p.position + 1 < p.tokens.len {
		p.next_token = p.tokens[p.position + 1]
	}
}

fn (mut p Parser) expect_token(kind TokenKind) ! {
	if p.current_token.kind != kind {
		return error('parser: expected token type must be `.slash`, but got `.${p.current_token.kind}`')
	}

	p.next()
}
