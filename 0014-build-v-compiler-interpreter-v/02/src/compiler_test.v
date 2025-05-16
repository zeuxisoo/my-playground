module main

fn test_compile_addition() {
	tree := BinOp{
		operator: '+'
		left: Int{3}
		right: Int{5}
	}
	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Number(Int{3})},
		Bytecode{BytecodeType.push, Number(Int{5})},
		Bytecode{BytecodeType.bin_op, '+'},
	]
}

fn test_compile_subtraction() {
	tree := BinOp{
		operator: '-'
		left: Int{5}
		right: Int{3}
	}
	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	assert bytecodes == [
		Bytecode{BytecodeType.push, Number(Int{5})},
		Bytecode{BytecodeType.push, Number(Int{3})},
		Bytecode{BytecodeType.bin_op, '-'},
	]
}
