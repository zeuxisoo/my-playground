module main

fn main() {
	mut calc := fn (code string) ! {
		mut tokenizer := Tokenizer.new(code)
		mut tokens := tokenizer.tokenize()!

		mut parser := Parser.new(tokens)
		mut tree := parser.parse()!

		mut compiler := Compiler.new(tree)
		mut bytecodes := compiler.compile()

		mut interpreter := Interpreter.new(bytecodes)
		mut result := interpreter.interpret()!

		value := flatten_result(result)
		/*
		// match
		value := match result {
			Number {
				match result as Number {
					Int {
						((result as Number) as Int).value.str()
					}
					Float {
						((result as Number) as Float).value.str()
					}
				}
			}
			string {
				result.str()
			}
		}

		// if
		value := if result is Number {
			number := result as Number

			if number is Int {
				number.value.str()
			} else if number is Float {
				number.value.str()
			} else {
				panic('Unknown type of result ${typeof(result).name}')
			}
		} else {
			result.str()
		}
		*/

		println('The result of "${code}" is "${value}"')
	}

	calc('3 + 5')!
	calc('3 + 5.9')!
	calc('3.1 + 5')!
	calc('8.1 + 7.9')!
}

fn flatten_result(result BytecodeValue) string {
	return match result {
		Number {
			match result {
				Int {
					(result as Int).value.str()
				}
				Float {
					(result as Float).value.str()
				}
			}
		}
		string {
			result.str()
		}
	}
}
