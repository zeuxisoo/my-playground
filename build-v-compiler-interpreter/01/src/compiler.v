module main

struct Compiler {
	tree BinOp
}

fn Compiler.new(tree BinOp) Compiler {
	return Compiler{
		tree: tree
	}
}

fn (self Compiler) compile() []Bytecode {
	left := self.tree.left
	right := self.tree.right
	operator := self.tree.operator

	return [
		Bytecode{BytecodeType.push, left.value.str()},
		Bytecode{BytecodeType.push, right.value.str()},
		Bytecode{BytecodeType.bin_op, operator},
	]
}
