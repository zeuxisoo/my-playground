module main

fn create_interpreter(code string) !Interpreter {
	mut tokenizer := Tokenizer.new(code)
	mut tokens := tokenizer.tokenize()!

	mut parser := Parser.new(tokens)
	mut tree := parser.parse()!

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	mut interpreter := Interpreter.new(bytecodes)

	return interpreter
}

fn interpret_code_result(code string) !BytecodeValue {
	mut interpreter := create_interpreter(code)!
	mut result := interpreter.interpret()!

	return result
}

fn interpret_code_get_scope(code string) !map[string]BytecodeValue {
	mut interpreter := create_interpreter(code)!

	interpreter.interpret()!

	return interpreter.get_scope()
}

fn test_interpret() {
	code_results := [
		CodeResult[Value]{'3 + 5', Int{8}},
		CodeResult[Value]{'5 - 2', Int{3}},
		CodeResult[Value]{'1 + 2', Int{3}},
		CodeResult[Value]{'1 - 9', Int{-8}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result as Value == code_result.expected
	}
}

fn test_arithmetic_with_floats() {
	code_results := [
		CodeResult[Value]{'3 + 5', Int{8}},
		CodeResult[Value]{'3 + 5.9', Float{8.9}},
		CodeResult[Value]{'3.1 + 5', Float{8.1}},
		CodeResult[Value]{'8.1 + 7.9', Float{16.0}},
		CodeResult[Value]{'103.6 + 5.4', Float{109.0}},
		CodeResult[Value]{'5.5 - 2', Float{3.5}},
		CodeResult[Value]{'1 + .2', Float{1.2}},
		CodeResult[Value]{'100.0625 + 9.5', Float{109.5625}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_sequences_of_additions_and_subtractions() {
	code_results := [
		CodeResult[Value]{'1 + 2 + 3 + 4 + 5', Int{15}},
		CodeResult[Value]{'1 - 2 - 3', Int{-4}},
		CodeResult[Value]{'1 - 2 + 3 - 4 + 5 - 6', Int{-3}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_compile_unary_minus() {
	tree := TreeNode(Expr(UnaryOp{
		operator: '-'
		value: Value(Int{3})
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile() == [
		Bytecode{BytecodeType.push, BytecodeValue(Value(Int{3}))},
		Bytecode{BytecodeType.unary_op, '-'},
	]
}

fn test_compile_unary_plus() {
	tree := TreeNode(Expr(UnaryOp{
		operator: '+'
		value: Value(Int{3})
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile() == [
		Bytecode{BytecodeType.push, BytecodeValue(Value(Int{3}))},
		Bytecode{BytecodeType.unary_op, '+'},
	]
}

fn test_compile_unary_operations() {
	tree := TreeNode(Expr(UnaryOp{
		operator: '-'
		value: UnaryOp{
			operator: '-'
			value: UnaryOp{
				operator: '+'
				value: UnaryOp{
					operator: '+'
					value: Value(Float{3.5})
				}
			}
		}
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile() == [
		Bytecode{BytecodeType.push, BytecodeValue(Value(Float{3.5}))},
		Bytecode{BytecodeType.unary_op, '+'},
		Bytecode{BytecodeType.unary_op, '+'},
		Bytecode{BytecodeType.unary_op, '-'},
		Bytecode{BytecodeType.unary_op, '-'},
	]
}

fn test_unary_operators() {
	code_results := [
		CodeResult[Value]{'-3', Int{-3}},
		CodeResult[Value]{'+3', Int{3}},
		CodeResult[Value]{'--3', Int{3}},
		CodeResult[Value]{'---3', Int{-3}},
		CodeResult[Value]{'----3', Int{3}},
		CodeResult[Value]{'--++-++-+3', Int{3}},
		CodeResult[Value]{'--3 + --3', Int{6}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_parenthesised_expressions() {
	code_results := [
		CodeResult[Value]{'-(3 + 2)', Int{-5}},
		CodeResult[Value]{'1 - (2 - 3)', Int{2}},
		CodeResult[Value]{'(((1))) + (2 + (3))', Int{6}},
		CodeResult[Value]{'(2 - 3) - (5 - 6)', Int{0}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_arithmetic_operator_precedence() {
	code_results := [
		CodeResult[string]{'2 + 3 * 4 + 5', '2 + (3 * 4) + 5'},
		CodeResult[string]{'2 - 3 * 4 - 5', '2 - (3 * 4) - 5'},
		CodeResult[string]{'2 + 3 / 5 + 7', '2 + (3 / 5) + 7'},
		CodeResult[string]{'20 % 4 * 10', '(20 % 4) * 10'},
		CodeResult[string]{'-2 ** -3', '- (2 ** -3)'},
		CodeResult[string]{'2 ** 3 * 4', '(2 ** 3) * 4'},
		CodeResult[string]{'2 * 3 ** 4', '2 * (3 ** 4)'},
		CodeResult[string]{'5 + 4 % 9', '5 + (4 % 9)'},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!
		expected := interpret_code_result(code_result.expected)!

		assert result == expected
	}
}

fn test_all_arithmetic_operators() {
	code_results := [
		CodeResult[Value]{'4 % 5 % 3', Int{1}},
		CodeResult[Value]{'2 * 3 * 4', Int{24}},
		CodeResult[Value]{'-2 ** 10', Float{-1024.0}},
		CodeResult[Value]{'2 / 2 / 1', Int{1}},
		CodeResult[Value]{'2 + 3 * 4 ** 5 - 6 % 7 / 8', Float{3074.0}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_simple_assignment() {
	code := 'a = 3'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 1
	assert scope['a']! == BytecodeValue(Value(Int{3}))
}

fn test_overriding_assignment() {
	code := 'a = 3\na = 4\na = 5'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 1
	assert scope['a']! == BytecodeValue(Value(Int{5}))
}

fn test_multiple_assignment_statements() {
	code := 'a = 1\nb = 2\na = 3\nc = 4\na = 5'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 3
	assert scope['a']! == BytecodeValue(Value(Int{5}))
	assert scope['b']! == BytecodeValue(Value(Int{2}))
	assert scope['c']! == BytecodeValue(Value(Int{4}))
}

fn test_assignments_and_references() {
	code_results := [
		CodeResult[map[string]BytecodeValue]{'a = 1\nb = 1\nc = a + b', {
			'a': BytecodeValue(Value(Int{1}))
			'b': BytecodeValue(Value(Int{1}))
			'c': BytecodeValue(Value(Int{2}))
		}},
		CodeResult[map[string]BytecodeValue]{'a = 1\nb = a\nc = b\na = 3', {
			'a': BytecodeValue(Value(Int{3}))
			'b': BytecodeValue(Value(Int{1}))
			'c': BytecodeValue(Value(Int{1}))
		}},
		CodeResult[map[string]BytecodeValue]{'a = b = c = 3', {
			'a': BytecodeValue(Value(Int{3}))
			'b': BytecodeValue(Value(Int{3}))
			'c': BytecodeValue(Value(Int{3}))
		}},
	]

	for code_result in code_results {
		result := interpret_code_get_scope(code_result.code)!

		assert result == code_result.expected
	}
}
