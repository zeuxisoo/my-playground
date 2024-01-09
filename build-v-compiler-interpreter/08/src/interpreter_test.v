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
		CodeResult[Constant]{'3 + 5', Constant{8}},
		CodeResult[Constant]{'5 - 2', Constant{3}},
		CodeResult[Constant]{'1 + 2', Constant{3}},
		CodeResult[Constant]{'1 - 9', Constant{-8}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result as Constant == code_result.expected
	}
}

fn test_interpreter_arithmetic_with_floats() {
	code_results := [
		CodeResult[Constant]{'3 + 5', Constant{8}},
		CodeResult[Constant]{'3 + 5.9', Constant{f32(8.9)}},
		CodeResult[Constant]{'3.1 + 5', Constant{f32(8.1)}},
		CodeResult[Constant]{'8.1 + 7.9', Constant{f32(16.0)}},
		CodeResult[Constant]{'103.6 + 5.4', Constant{f32(109.0)}},
		CodeResult[Constant]{'5.5 - 2', Constant{f32(3.5)}},
		CodeResult[Constant]{'1 + .2', Constant{f32(1.2)}},
		CodeResult[Constant]{'100.0625 + 9.5', Constant{f32(109.5625)}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_interpreter_sequences_of_additions_and_subtractions() {
	code_results := [
		CodeResult[Constant]{'1 + 2 + 3 + 4 + 5', Constant{15}},
		CodeResult[Constant]{'1 - 2 - 3', Constant{-4}},
		CodeResult[Constant]{'1 - 2 + 3 - 4 + 5 - 6', Constant{-3}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_interpreter_unary_operators() {
	code_results := [
		CodeResult[Constant]{'-3', Constant{-3}},
		CodeResult[Constant]{'+3', Constant{3}},
		CodeResult[Constant]{'--3', Constant{3}},
		CodeResult[Constant]{'---3', Constant{-3}},
		CodeResult[Constant]{'----3', Constant{3}},
		CodeResult[Constant]{'--++-++-+3', Constant{3}},
		CodeResult[Constant]{'--3 + --3', Constant{6}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_interpreter_parenthesised_expressions() {
	code_results := [
		CodeResult[Constant]{'-(3 + 2)', Constant{-5}},
		CodeResult[Constant]{'1 - (2 - 3)', Constant{2}},
		CodeResult[Constant]{'(((1))) + (2 + (3))', Constant{6}},
		CodeResult[Constant]{'(2 - 3) - (5 - 6)', Constant{0}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_interpreter_arithmetic_operator_precedence() {
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

fn test_interpreter_all_arithmetic_operators() {
	code_results := [
		CodeResult[Constant]{'4 % 5 % 3', Constant{1}},
		CodeResult[Constant]{'2 * 3 * 4', Constant{24}},
		CodeResult[Constant]{'-2 ** 10', Constant{f32(-1024.0)}},
		CodeResult[Constant]{'2 / 2 / 1', Constant{1}},
		CodeResult[Constant]{'2 + 3 * 4 ** 5 - 6 % 7 / 8', Constant{f32(3074.0)}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == BytecodeValue(code_result.expected)
	}
}

fn test_interpreter_simple_assignment() {
	code := 'a = 3'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 1
	assert scope['a']! == BytecodeValue(Constant{3})
}

fn test_interpreter_overriding_assignment() {
	code := 'a = 3\na = 4\na = 5'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 1
	assert scope['a']! == BytecodeValue(Constant{5})
}

fn test_interpreter_multiple_assignment_statements() {
	code := 'a = 1\nb = 2\na = 3\nc = 4\na = 5'
	scope := interpret_code_get_scope(code)!

	assert scope.len == 3
	assert scope['a']! == BytecodeValue(Constant{5})
	assert scope['b']! == BytecodeValue(Constant{2})
	assert scope['c']! == BytecodeValue(Constant{4})
}

fn test_interpreter_assignments_and_references() {
	code_results := [
		CodeResult[map[string]BytecodeValue]{'a = 1\nb = 1\nc = a + b', {
			'a': BytecodeValue(Constant{1})
			'b': BytecodeValue(Constant{1})
			'c': BytecodeValue(Constant{2})
		}},
		CodeResult[map[string]BytecodeValue]{'a = 1\nb = a\nc = b\na = 3', {
			'a': BytecodeValue(Constant{3})
			'b': BytecodeValue(Constant{1})
			'c': BytecodeValue(Constant{1})
		}},
		CodeResult[map[string]BytecodeValue]{'a = b = c = 3', {
			'a': BytecodeValue(Constant{3})
			'b': BytecodeValue(Constant{3})
			'c': BytecodeValue(Constant{3})
		}},
	]

	for code_result in code_results {
		result := interpret_code_get_scope(code_result.code)!

		assert result == code_result.expected
	}
}

fn test_interpreter_flat_conditionals() {
	code := '
if 1:
    a = 1
    b = 1
if 0:
    a = 20
    b = 20

if a:
    c = 11 - 10
'

	assert interpret_code_get_scope(code)! == {
		'a': BytecodeValue(Constant{1})
		'b': BytecodeValue(Constant{1})
		'c': BytecodeValue(Constant{1})
	}
}

fn test_interpreter_nested_conditionals() {
	code := '
if 1:
    if 1:
        a = 1

        if 0:
            c = 1

    if a:
        b = 1

    if 5 - 5:
        c = 1
'

	assert interpret_code_get_scope(code)! == {
		'a': BytecodeValue(Constant{1})
		'b': BytecodeValue(Constant{1})
	}
}

fn test_interpreter_booleans() {
	code := '
if true:
    a = 73

if false:
    b = 73
'
	assert interpret_code_get_scope(code)! == {
		'a': BytecodeValue(Constant{73})
	}
}

fn test_interpreter_not() {
	code_results := [
		CodeResult[BytecodeValue]{'not true', Constant{false}},
		CodeResult[BytecodeValue]{'not not true', Constant{true}},
		CodeResult[BytecodeValue]{'not not not true', Constant{false}},
		CodeResult[BytecodeValue]{'not not not not true', Constant{true}},
		CodeResult[BytecodeValue]{'not false', Constant{true}},
		CodeResult[BytecodeValue]{'not not false', Constant{false}},
		CodeResult[BytecodeValue]{'not not not false', Constant{true}},
		CodeResult[BytecodeValue]{'not not not not false', Constant{false}},
		CodeResult[BytecodeValue]{'+true', Constant{1}},
		CodeResult[BytecodeValue]{'+false', Constant{0}},
		CodeResult[BytecodeValue]{'-true', Constant{-1}},
		CodeResult[BytecodeValue]{'-false', Constant{0}},
	]

	for code_result in code_results {
		result := interpret_code_result(code_result.code)!

		assert result == code_result.expected
	}
}
