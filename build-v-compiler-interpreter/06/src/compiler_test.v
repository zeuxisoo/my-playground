module main

fn test_compile_addition() {
	tree := Expr(BinOp{
		operator: '+'
		left: Value(Int{3})
		right: Value(Int{5})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.push, Value(Int{5})},
		Bytecode{BytecodeType.bin_op, '+'},
	]
}

fn test_compile_subtraction() {
	tree := Expr(BinOp{
		operator: '-'
		left: Value(Int{5})
		right: Value(Int{3})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{5})},
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.bin_op, '-'},
	]
}

fn test_compile_nested_additions_and_subtractions() {
	tree := Expr(BinOp{
		operator: '-'
		left: BinOp{
			operator: '+'
			left: BinOp{
				operator: '+'
				left: BinOp{
					operator: '-'
					left: BinOp{
						operator: '+'
						left: Value(Int{3})
						right: Value(Int{5})
					}
					right: Value(Int{7})
				}
				right: Value(Float{1.2})
			}
			right: Value(Float{2.4})
		}
		right: Value(Float{3.6})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.push, Value(Int{5})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Value(Int{7})},
		Bytecode{BytecodeType.bin_op, '-'},
		Bytecode{BytecodeType.push, Value(Float{1.2})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Value(Float{2.4})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Value(Float{3.6})},
		Bytecode{BytecodeType.bin_op, '-'},
	]
}

fn test_compile_multiplication() {
	tree := Expr(BinOp{
		operator: '*'
		left: Value(Int{3})
		right: Value(Float{3.14})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.push, Value(Float{3.14})},
		Bytecode{BytecodeType.bin_op, '*'},
	]
}

fn test_compile_division() {
	tree := Expr(BinOp{
		operator: '/'
		left: Value(Int{1})
		right: Value(Int{2})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{1})},
		Bytecode{BytecodeType.push, Value(Int{2})},
		Bytecode{BytecodeType.bin_op, '/'},
	]
}

fn test_compile_exponentiation() {
	tree := Expr(BinOp{
		operator: '**'
		left: Value(Float{0.1})
		right: Value(Float{3.14})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Float{0.1})},
		Bytecode{BytecodeType.push, Value(Float{3.14})},
		Bytecode{BytecodeType.bin_op, '**'},
	]
}

fn test_compile_modulo() {
	tree := Expr(BinOp{
		operator: '%'
		left: Value(Int{-3})
		right: Value(Float{5.6})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{-3})},
		Bytecode{BytecodeType.push, Value(Float{5.6})},
		Bytecode{BytecodeType.bin_op, '%'},
	]
}

fn test_compile_program_and_expr_statement() {
	tree := Program{
		statements: [
			ExprStatement{
				expr: Value(Int{1})
			},
			ExprStatement{
				expr: Value(Float{2.0})
			},
			ExprStatement{
				expr: BinOp{
					operator: '+'
					left: Value(Float{3.0})
					right: Value(Float{4.0})
				}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{1})},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Value(Float{2.0})},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Value(Float{3.0})},
		Bytecode{BytecodeType.push, Value(Float{4.0})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.pop, 'pop'},
	]
}

fn test_compile_assignment() {
	tree := Statement(Assignment{
		targets: [
			Variable{
				name: '_123'
			},
		]
		value: Value(Int{3})
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.save, '_123'},
	]
}

fn test_compile_program_with_assignments() {
	tree := Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
				]
				value: Value(Int{3})
			},
			ExprStatement{
				expr: BinOp{
					operator: '**'
					left: Value(Int{4})
					right: Value(Int{5})
				}
			},
			Assignment{
				targets: [
					Variable{'b'},
				]
				value: Value(Int{7})
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.save, 'a'},
		Bytecode{BytecodeType.push, Value(Int{4})},
		Bytecode{BytecodeType.push, Value(Int{5})},
		Bytecode{BytecodeType.bin_op, '**'},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Value(Int{7})},
		Bytecode{BytecodeType.save, 'b'},
	]
}

fn test_compile_variable_reference() {
	tree := Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
				]
				value: BinOp{
					operator: '+'
					left: Value(Variable{'b'})
					right: Value(Int{3})
				}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.load, Value(Variable{'b'})},
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.save, 'a'},
	]
}

fn test_compile_consecutive_assignments() {
	tree := Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
					Variable{'b'},
					Variable{'c'},
				]
				value: Value(Int{3})
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Value(Int{3})},
		Bytecode{BytecodeType.copy, 'copy'},
		Bytecode{BytecodeType.save, 'a'},
		Bytecode{BytecodeType.copy, 'copy'},
		Bytecode{BytecodeType.save, 'b'},
		Bytecode{BytecodeType.save, 'c'},
	]
}
