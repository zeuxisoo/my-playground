module main

fn test_compile_addition() {
	tree := Expr(BinOp{
		operator: '+'
		left: Number(Int{3})
		right: Number(Int{5})
	})
	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Number(Int{3})},
		Bytecode{BytecodeType.push, Number(Int{5})},
		Bytecode{BytecodeType.bin_op, '+'},
	]
}

fn test_compile_subtraction() {
	tree := Expr(BinOp{
		operator: '-'
		left: Number(Int{5})
		right: Number(Int{3})
	})
	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Number(Int{5})},
		Bytecode{BytecodeType.push, Number(Int{3})},
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
						left: Number(Int{3})
						right: Number(Int{5})
					}
					right: Number(Int{7})
				}
				right: Number(Float{1.2})
			}
			right: Number(Float{2.4})
		}
		right: Number(Float{3.6})
	})
	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Number(Int{3})},
		Bytecode{BytecodeType.push, Number(Int{5})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Number(Int{7})},
		Bytecode{BytecodeType.bin_op, '-'},
		Bytecode{BytecodeType.push, Number(Float{1.2})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Number(Float{2.4})},
		Bytecode{BytecodeType.bin_op, '+'},
		Bytecode{BytecodeType.push, Number(Float{3.6})},
		Bytecode{BytecodeType.bin_op, '-'},
	]
}
