module main

fn test_compile_addition() {
	tree := Expr(BinOp{
		operator: '+'
		left: Constant{3}
		right: Constant{5}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
		Bytecode{BytecodeType.push, Constant{5}},
		Bytecode{BytecodeType.bin_op, '+'},
	]
}

fn test_compile_subtraction() {
	tree := Expr(BinOp{
		operator: '-'
		left: Constant{5}
		right: Constant{3}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{5}},
		Bytecode{BytecodeType.push, Constant{3}},
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
						left: Constant{3}
						right: Constant{5}
					}
					right: Constant{7}
				}
				right: Constant{f32(1.2)}
			}
			right: Constant{f32(2.4)}
		}
		right: Constant{f32(3.6)}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
		Bytecode{BytecodeType.push, Constant{5}},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Constant{7}},
		Bytecode{BytecodeType.bin_op, '-'},
		Bytecode{BytecodeType.push, Constant{f32(1.2)}},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Constant{f32(2.4)}},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Constant{f32(3.6)}},
		Bytecode{BytecodeType.bin_op, '-'},
	]
}

fn test_compile_multiplication() {
	tree := Expr(BinOp{
		operator: '*'
		left: Constant{3}
		right: Constant{f32(3.14)}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
		Bytecode{BytecodeType.push, Constant{f32(3.14)}},
		Bytecode{BytecodeType.bin_op, '*'},
	]
}

fn test_compile_division() {
	tree := Expr(BinOp{
		operator: '/'
		left: Constant{1}
		right: Constant{2}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{1}},
		Bytecode{BytecodeType.push, Constant{2}},
		Bytecode{BytecodeType.bin_op, '/'},
	]
}

fn test_compile_exponentiation() {
	tree := Expr(BinOp{
		operator: '**'
		left: Constant{f32(0.1)}
		right: Constant{f32(3.14)}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{f32(0.1)}},
		Bytecode{BytecodeType.push, Constant{f32(3.14)}},
		Bytecode{BytecodeType.bin_op, '**'},
	]
}

fn test_compile_modulo() {
	tree := Expr(BinOp{
		operator: '%'
		left: Constant{-3}
		right: Constant{f32(5.6)}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{-3}},
		Bytecode{BytecodeType.push, Constant{f32(5.6)}},
		Bytecode{BytecodeType.bin_op, '%'},
	]
}

fn test_compile_unary_minus() {
	tree := TreeNode(Expr(UnaryOp{
		operator: '-'
		value: Constant{3}
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile()! == [
		Bytecode{BytecodeType.push, BytecodeValue(Constant{3})},
		Bytecode{BytecodeType.unary_op, '-'},
	]
}

fn test_compile_unary_plus() {
	tree := TreeNode(Expr(UnaryOp{
		operator: '+'
		value: Constant{3}
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile()! == [
		Bytecode{BytecodeType.push, BytecodeValue(Constant{3})},
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
					value: Constant{f32(3.5)}
				}
			}
		}
	}))

	mut compiler := Compiler.new(tree)

	assert compiler.compile()! == [
		Bytecode{BytecodeType.push, BytecodeValue(Constant{f32(3.5)})},
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
				expr: Constant{1}
			},
			ExprStatement{
				expr: Constant{f32(2.0)}
			},
			ExprStatement{
				expr: BinOp{
					operator: '+'
					left: Constant{f32(3.0)}
					right: Constant{f32(4.0)}
				}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{1}},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Constant{f32(2.0)}},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Constant{f32(3.0)}},
		Bytecode{BytecodeType.push, Constant{f32(4.0)}},
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
		value: Constant{3}
	})

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
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
				value: Constant{3}
			},
			ExprStatement{
				expr: BinOp{
					operator: '**'
					left: Constant{4}
					right: Constant{5}
				}
			},
			Assignment{
				targets: [
					Variable{'b'},
				]
				value: Constant{7}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
		Bytecode{BytecodeType.save, 'a'},
		Bytecode{BytecodeType.push, Constant{4}},
		Bytecode{BytecodeType.push, Constant{5}},
		Bytecode{BytecodeType.bin_op, '**'},
		Bytecode{BytecodeType.pop, 'pop'},
		Bytecode{BytecodeType.push, Constant{7}},
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
					left: Variable{'b'}
					right: Constant{3}
				}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.load, Variable{'b'}},
		Bytecode{BytecodeType.push, Constant{3}},
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
				value: Constant{3}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{3}},
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
				condition: Variable{'cond'}
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'visited'},
							]
							value: Constant{1}
						},
					]
				}
			},
			Assignment{
				targets: [
					Variable{'done'},
				]
				value: Constant{1}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.load, Variable{'cond'}},
		Bytecode{BytecodeType.pop_jump_if_false, '3'},
		Bytecode{BytecodeType.push, Constant{1}},
		Bytecode{BytecodeType.save, 'visited'},
		Bytecode{BytecodeType.push, Constant{1}},
		Bytecode{BytecodeType.save, 'done'},
	]
}

fn test_compile_multiple_conditionals() {
	tree := Program{
		statements: [
			Conditional{
				condition: Variable{'one'}
				body: Body{
					statements: [
						Assignment{
							targets: [
								Variable{'two'},
							]
							value: Constant{2}
						},
						Conditional{
							condition: Variable{'three'}
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'four'},
										]
										value: Constant{4}
									},
									Assignment{
										targets: [
											Variable{'five'},
										]
										value: Constant{5}
									},
								]
							}
						},
						Conditional{
							condition: Variable{'six'}
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'seven'},
										]
										value: Constant{7}
									},
								]
							}
						},
						Assignment{
							targets: [
								Variable{'eight'},
							]
							value: Constant{8}
						},
						Conditional{
							condition: Variable{'nine'}
							body: Body{
								statements: [
									Assignment{
										targets: [
											Variable{'ten'},
										]
										value: Constant{10}
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
				value: Constant{11}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		// vfmt off
		Bytecode{BytecodeType.load, Variable{'one'}}, 	// 0
		Bytecode{BytecodeType.pop_jump_if_false, '19'}, // 1 >> 20 (1 + 19)
		Bytecode{BytecodeType.push, Constant{2}}, 		// 2
		Bytecode{BytecodeType.save, 'two'}, 			// 3
		Bytecode{BytecodeType.load, Variable{'three'}},	// 4
		Bytecode{BytecodeType.pop_jump_if_false, '5'}, 	// 5 >> 10 (5 + 5)
		Bytecode{BytecodeType.push, Constant{4}}, 		// 6
		Bytecode{BytecodeType.save, 'four'},			// 7
		Bytecode{BytecodeType.push, Constant{5}},		// 8
		Bytecode{BytecodeType.save, 'five'},			// 9
		Bytecode{BytecodeType.load, Variable{'six'}},	// 10 <<
		Bytecode{BytecodeType.pop_jump_if_false, '3'},	// 11 >> 14 (11 + 3)
		Bytecode{BytecodeType.push, Constant{7}},		// 12
		Bytecode{BytecodeType.save, 'seven'},			// 13
		Bytecode{BytecodeType.push, Constant{8}},		// 14 <<
		Bytecode{BytecodeType.save, 'eight'},			// 15
		Bytecode{BytecodeType.load, Variable{'nine'}},	// 16
		Bytecode{BytecodeType.pop_jump_if_false, '3'},	// 17 >> 20 (17 + 3)
		Bytecode{BytecodeType.push, Constant{10}},		// 18
		Bytecode{BytecodeType.save, 'ten'},				// 19
		Bytecode{BytecodeType.push, Constant{11}},		// 20 << <<
		Bytecode{BytecodeType.save, 'eleven'},			// 21
		// vfmt on
	]
}

fn test_compile_booleans() {
	tree := Program{
		statements: [
			Assignment{
				targets: [
					Variable{'a'},
				]
				value: Constant{true}
			},
			Assignment{
				targets: [
					Variable{'b'},
				]
				value: Constant{false}
			},
		]
	}

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()!

	assert bytecodes == [
		Bytecode{BytecodeType.push, Constant{true}},
		Bytecode{BytecodeType.save, 'a'},
		Bytecode{BytecodeType.push, Constant{false}},
		Bytecode{BytecodeType.save, 'b'},
	]
}

fn test_compile_and_short_circuiting() {
	operator_jump_types := [
		OperatorJumpTypes{'and', BytecodeType.pop_jump_if_false},
		OperatorJumpTypes{'or', BytecodeType.pop_jump_if_true},
	]

	for code in operator_jump_types {
		tree := Program{
			statements: [
				ExprStatement{BoolOp{
					operator: code.operator
					values: [
						BinOp{
							operator: '+'
							left: Constant{1}
							right: Constant{2}
						},
						Variable{'c'},
						BinOp{
							operator: '+'
							left: Constant{3}
							right: Constant{5}
						},
					]
				}},
			]
		}

		mut compiler := Compiler.new(tree)
		mut bytecodes := compiler.compile()!

		assert bytecodes == [
			Bytecode{BytecodeType.push, Constant{1}},
			Bytecode{BytecodeType.push, Constant{2}},
			Bytecode{BytecodeType.bin_op, '+'},
			Bytecode{BytecodeType.copy, 'copy'},
			Bytecode{code.jump_type, Constant{9}},
			Bytecode{BytecodeType.pop, 'pop'},
			Bytecode{BytecodeType.load, Variable{'c'}},
			Bytecode{BytecodeType.copy, 'copy'},
			Bytecode{code.jump_type, Constant{5}},
			Bytecode{BytecodeType.pop, 'pop'},
			Bytecode{BytecodeType.push, Constant{3}},
			Bytecode{BytecodeType.push, Constant{5}},
			Bytecode{BytecodeType.bin_op, '+'},
			Bytecode{BytecodeType.pop, 'pop'},
		]
	}
}
