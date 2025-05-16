module main

struct CodeResult {
	code     string
	expected int
}

fn test_interpret() {
	code_results := [
		CodeResult{'3 + 5', 8},
		CodeResult{'5 - 2', 3},
		CodeResult{'1 + 2', 3},
		CodeResult{'1 - 9', -8},
	]

	for code_result in code_results {
		mut tokenizer := Tokenizer.new(code_result.code)
		mut tokens := tokenizer.tokenize()!

		mut parser := Parser.new(tokens)
		mut tree := parser.parse()!

		mut compiler := Compiler.new(tree)
		mut bytecodes := compiler.compile()

		mut interpreter := Interpreter.new(bytecodes)
		mut result := interpreter.interpret()!

		assert result == code_result.expected
	}
}
