module main

fn interpret_code_result(code string) !BytecodeValue {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := tokenizer.tokenize()!

	mut parser := Parser.new(tokens)
	mut tree := parser.parse()!

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	mut interpreter := Interpreter.new(bytecodes)
	mut result := interpreter.interpret()!

	return result
}

fn test_interpret() {
	code_results := [
		CodeResult[Number]{'3 + 5', Int{8}},
		CodeResult[Number]{'5 - 2', Int{3}},
		CodeResult[Number]{'1 + 2', Int{3}},
		CodeResult[Number]{'1 - 9', Int{-8}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result as Number == code_result.expected
	}
}

fn test_arithmetic_with_floats() {
	code_results := [
		CodeResult[Number]{'3 + 5', Int{8}},
		CodeResult[Number]{'3 + 5.9', Float{8.9}},
		CodeResult[Number]{'3.1 + 5', Float{8.1}},
		CodeResult[Number]{'8.1 + 7.9', Float{16.0}},
		CodeResult[Number]{'103.6 + 5.4', Float{109.0}},
		CodeResult[Number]{'5.5 - 2', Float{3.5}},
		CodeResult[Number]{'1 + .2', Float{1.2}},
		CodeResult[Number]{'100.0625 + 9.5', Float{109.5625}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}
