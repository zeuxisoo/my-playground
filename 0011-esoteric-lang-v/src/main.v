module main

fn main() {
	// dump('12345'.bytes())
	// dump('Hello'.bytes())

	// 3 (1 + 2)
	println(
		eval_code('$ ------------------------------------------------ ~> $ [ <~ + ~> - ] <~ look', '12')
	)

	// Hello World!
	println(
		eval_code('++++++++++[~>+~>+++~>+++++++~>++++++++++<~<~<~<~-]~>~>~>++look~>+look+++++++look+++look<~<~++look~>+++++++++++++++look~>look+++look------look--------look<~<~+look', '')
	)

	// 7 (3 + 4)
	println(
		eval_code('$ ~> $ ~> ++++ [ <~ <~ + ~> ~> - ] <~ <~ look', '34')
	)
}

fn eval_code(code string, input string) string {
	lexer := new_lexer()

	tokens := lexer.tokenise(code) or {
		eprintln(err)
		exit(1)
	}

	mut parser := new_parser()
	program := parser.parse(tokens) or {
		eprintln(err)
		exit(1)
	}

	mut interpreter := new_interpreter()
	interpreter.interpret(program, input)

	return interpreter.result()
}
