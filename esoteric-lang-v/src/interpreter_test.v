module main

fn test_interpreter() {
	samples := [
		{
			'code'    : '$ ------------------------------------------------ ~> $ [ <~ + ~> - ] <~ look'
			'input'   : '12',
			'expected': '3',
		},
		{
			'code'    : '++++++++++[~>+~>+++~>+++++++~>++++++++++<~<~<~<~-]~>~>~>++look~>+look+++++++looklook+++look<~<~++look~>+++++++++++++++look~>look+++look------look--------look<~<~+look'
			'input'   : '',
			'expected': 'Hello World!'
		}
	]

	for sample in samples {
		result := run_interpreter(sample['code'], sample['input'])!

		assert result == sample['expected']
	}
}

fn run_interpreter(code string, input string) !string {
	tokens := new_lexer().tokenise(code)!

	mut parser := new_parser()
	program := parser.parse(tokens)!

	mut interpreter := new_interpreter()
	interpreter.interpret(program, input)

	return interpreter.result()
}
