module main

import tokenizer { tokenize }
import parser { parse }
import transformer { transform }
import generator { generate }

fn compile(input string) string {
	tokens := tokenize(input)
	parse_ast := parse(tokens)
	transform_ast := transform(parse_ast)
	code := generate(transform_ast)

	return code
}
