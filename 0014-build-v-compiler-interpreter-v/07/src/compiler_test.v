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

fn test_compile_single_conditional() {
	tree := Program{
		statements: [
			Conditional{
				condition: Value(Variable{'cond'})
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'visited'},
							]
							value: Value(Int{1})
						},
					]
				}
			},
			Assignment{
				targets: [
					Variable{'done'},
				]
				value: Value(Int{1})
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.load, Value(Variable{'cond'})},
		Bytecode{BytecodeType.pop_jump_if_false, '3'},
		Bytecode{BytecodeType.push, Value(Int{1})},
		Bytecode{BytecodeType.save, 'visited'},
		Bytecode{BytecodeType.push, Value(Int{1})},
		Bytecode{BytecodeType.save, 'done'},
	]
}

fn test_compile_multiple_conditionals() {
	tree := Program{
		statements: [
			Conditional{
				condition: Value(Variable{'one'})
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'two'},
							]
							value: Value(Int{2})
						},
						Conditional{
							condition: Value(Variable{'three'})
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'four'},
										]
										value: Value(Int{4})
									},
									Assignment{
										targets: [
											Variable{'five'},
										]
										value: Value(Int{5})
									},
								]
							}
						},
						Conditional{
							condition: Value(Variable{'six'})
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'seven'},
										]
										value: Value(Int{7})
									},
								]
							}
						},
						Assignment{
							targets: [
								Variable{'eight'},
							]
							value: Value(Int{8})
						},
						Conditional{
							condition: Value(Variable{'nine'})
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'ten'},
										]
										value: Value(Int{10})
									},
								]
							}
						},
					]
				}
			},
			Assignment{
				targets: [
					Variable{'eleven'},
				]
				value: Value(Int{11})
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		// vfmt off
		Bytecode{BytecodeType.load, Value(Variable{'one'})}, 	// 0
		Bytecode{BytecodeType.pop_jump_if_false, '19'}, 		// 1 >> 20 (1 + 19)
		Bytecode{BytecodeType.push, Value(Int{2})}, 			// 2
		Bytecode{BytecodeType.save, 'two'}, 	// 3
		Bytecode{BytecodeType.load, Value(Variable{'three'})},	// 4
		Bytecode{BytecodeType.pop_jump_if_false, '5'}, 			// 5 >> 10 (5 + 5)
		Bytecode{BytecodeType.push, Value(Int{4})}, 			// 6
		Bytecode{BytecodeType.save, 'four'},	// 7
		Bytecode{BytecodeType.push, Value(Int{5})},				// 8
		Bytecode{BytecodeType.save, 'five'},	// 9
		Bytecode{BytecodeType.load, Value(Variable{'six'})},	// 10 <<
		Bytecode{BytecodeType.pop_jump_if_false, '3'},			// 11 >> 14 (11 + 3)
		Bytecode{BytecodeType.push, Value(Int{7})},				// 12
		Bytecode{BytecodeType.save, 'seven'},	// 13
		Bytecode{BytecodeType.push, Value(Int{8})},				// 14 <<
		Bytecode{BytecodeType.save, 'eight'},	// 15
		Bytecode{BytecodeType.load, Value(Variable{'nine'})},	// 16
		Bytecode{BytecodeType.pop_jump_if_false, '3'},			// 17 >> 20 (17 + 3)
		Bytecode{BytecodeType.push, Value(Int{10})},			// 18
		Bytecode{BytecodeType.save, 'ten'},	// 19
		Bytecode{BytecodeType.push, Value(Int{11})},			// 20 << <<
		Bytecode{BytecodeType.save, 'eleven'},	// 21
		// vfmt on
	]
}
