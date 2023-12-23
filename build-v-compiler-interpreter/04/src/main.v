module main

@[params]
struct MainOption {
	print_tree   bool
	iter_compile bool
}

fn main() {
	mut calc := fn (code string, option MainOption) ! {
		mut tokenizer := Tokenizer.new(code)
		mut tokens := tokenizer.tokenize()!

		mut parser := Parser.new(tokens)
		mut tree := parser.parse()!

		mut compiler := Compiler.new(tree)
		mut bytecodes := compiler.compile()

		mut interpreter := Interpreter.new(bytecodes)
		mut result := interpreter.interpret()!

		value := flatten_result(result)

		println('The result of "${code}" is "${value}"')

		if option.print_tree {
			print_ast(tree, 0)
		}

		if option.iter_compile {
			for b in compiler.iter() {
				println(b)
			}
		}

		println('') // newline
	}

	// calc('3 + 5')!
	// calc('3 + 5.9')!
	// calc('3.1 + 5')!
	// calc('8.1 + 7.9')!
	// calc('3 + 5 - 7')!

	// result: 1.000001
	// f32: 1.000001 (<-- current type)
	// f64: 0.9999999999999996
	// calc('3 + 5 - 7 + 1.2 + 2.4 - 3.6', print_tree: true, iter_compile: true)!

	// calc('--++3.5 - 2', print_tree: true)!
	// calc('1 + (2 + 3)', print_tree: true)!

	calc('2 + 3 * 4 ** 5 - 6 % 7 / 8')!
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
