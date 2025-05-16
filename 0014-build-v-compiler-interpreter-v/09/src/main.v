module main

@[params]
struct MainOption {
	print_tree   bool
	print_scope  bool
	iter_compile bool
}

/*
fn main() {
	mut token := Tokenizer.new('1 or 2')
	mut tokens := token.tokenize()!

	mut parser := Parser.new(tokens)
	mut tree := parser.parse()!

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	mut interpreter := Interpreter.new(bytecodes)
	mut result := interpreter.interpret()!

	dump(result)
}
*/

fn main() {
	mut calc := fn (code string, option MainOption) ! {
		mut tokenizer := Tokenizer.new(code)
		mut tokens := tokenizer.tokenize()!

		mut parser := Parser.new(tokens)
		mut tree := parser.parse()!

		mut compiler := Compiler.new(tree)
		mut bytecodes := compiler.compile()!

		mut interpreter := Interpreter.new(bytecodes)
		mut result := interpreter.interpret()!

		value := flatten_result(result)

		println('The result of "${code}" is "${value}"')

		if option.print_tree {
			print_ast(tree, 0)
		}

		if option.print_scope {
			println(interpreter.get_scope())
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

	// // result: 1.000001
	// // f32: 1.000001 (<-- current type)
	// // f64: 0.9999999999999996
	// calc('3 + 5 - 7 + 1.2 + 2.4 - 3.6', print_tree: true, iter_compile: true)!

	// calc('--++3.5 - 2', print_tree: true)!
	// calc('1 + (2 + 3)', print_tree: true)!

	// calc('1 + 2\n3 + 4\n5 + 6\n', print_tree: true, iter_compile: true)!

	// calc('a = 3 \n b = 7 \n d = 2 ** 2 % 4', print_tree: true)!
	// calc('a = 1\nb = 1\nc = a + b', print_scope: true)!
	// calc('a = b = c = 3', print_tree: true, print_scope: true, iter_compile: true)!

	calc('if 3 ** 4 - 80:\n    a = 3\n    b = 5', print_tree: true)!
	calc('if 1:\n    a = 3\n    b = a\n    if 2:\n        c = 3', print_tree: true)!
	calc('1', print_tree: true)!
	// vfmt off
    calc('
if 1:
    a = 1
    b = 1
if 0:
    a = 20
    b = 20

if a:
    c = 11 - 10
    ', print_scope: true)!
    calc('
if 1:
    if 1:
        a = 1

        if 0:
            c = 1

    if a:
        b = 1

    if 5 - 5:
        c = 1
    ', print_scope: true)!
    calc('
if false:
    a = 73
    ', print_scope: true)!
	// vfmt on
}

fn flatten_result(result BytecodeValue) string {
	return match result {
		Constant {
			constant_result := result.value

			match constant_result {
				int {
					constant_result.str()
				}
				f32 {
					constant_result.str()
				}
				bool {
					constant_result.str()
				}
			}
		}
		Variable {
			(result as Variable).name.str()
		}
		string {
			result.str()
		}
	}
}
