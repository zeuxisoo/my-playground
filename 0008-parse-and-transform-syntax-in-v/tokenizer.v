module tokenizer

import regex

//
pub struct Token {
pub:
	kind  string
	value string
}

//
const (
	letter     = r'[a-z]'
	whitespace = r'\s'
	number     = r'\d'
)

//
pub fn tokenize(input string) []Token {
	mut tokens := []Token{}
	mut current := 0

	rune_input := input.runes()

	for current < rune_input.len {
		mut chr := rune_input[current]

		if chr == `(` || chr == `)` {
			tokens << Token{
				kind: 'paren'
				value: chr.str()
			}
			current = current + 1
			continue
		}

		if match_string(tokenizer.letter, chr.str()) {
			mut value := []rune{}

			for match_string(tokenizer.letter, chr.str()) {
				value << chr
				current = current + 1
				chr = rune_input[current]
			}
			tokens << Token{
				kind: 'name'
				value: value.string()
			}
			continue
		}

		if match_string(tokenizer.whitespace, chr.str()) {
			current = current + 1
			continue
		}

		if match_string(tokenizer.number, chr.str()) {
			mut value := []rune{}

			for match_string(tokenizer.number, chr.str()) {
				value << chr
				current = current + 1
				chr = rune_input[current]
			}
			tokens << Token{
				kind: 'number'
				value: value.string()
			}
			continue
		}

		panic('Unknown char: `${chr}`')
	}

	return tokens
}

fn match_string(pattern string, text string) bool {
	re := regex.regex_opt(pattern) or { panic(err) }

	return re.matches_string(text)
}
