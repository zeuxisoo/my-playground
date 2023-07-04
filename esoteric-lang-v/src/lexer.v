module main

struct Lexer {
	error LexerError
}

fn new_lexer() &Lexer {
	return &Lexer{ new_lexer_error() }
}

fn (l Lexer) tokenise(input string) ![]Token {
	mut tokens := []Token{}

	chars := input.runes()

	for i := 0; i<chars.len; i++ {
		chr := chars[i]

		match chr {
			`~` {
				i = i + 1

				if chars[i] == `>` {
					tokens << new_token(.right_tilde_arrow)
				}else{
					return l.error.unexpected_token_after(chars[i].str(), '>', '~', i)
				}
			}
			`<` {
				i = i + 1

				if chars[i] == `~` {
					tokens << new_token(.left_tilde_arrow)
				}else{
					return l.error.unexpected_token_after(chars[i].str(), '~', '<', i)
				}
			}
			`+` {
				tokens << new_token(.plus)
			}
			`-` {
				tokens << new_token(.minus)
			}
			`l` {
				peek_i := i + 4 // before peek_i position `i < i+1`

				if peek_i > chars.len {
					return l.error.out_of_content_range(peek_i, chars.len, i)
				}

				if chars[i..peek_i] != 'look'.runes() {
					return l.error.unexpected_token(chars[i..peek_i].string(), 'look', i)
				}

				tokens << new_token(.look)

				i = peek_i - 1 // move to previous position
			}
			`$` {
				tokens << new_token(.dollar)
			}
			`[` {
				tokens << new_token(.left_brackets)
			}
			`]` {
				tokens << new_token(.right_brackets)
			}
			` ` {
				continue
			}
			else{
				return l.error.unknown_token(chr.str(),  i)
			}
		}
	}

	return tokens
}
