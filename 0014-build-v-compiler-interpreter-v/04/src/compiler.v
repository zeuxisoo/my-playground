module main

struct Compiler {
	tree TreeNode
mut:
	bytecodes      []Bytecode
	bytecode_index int
}

fn Compiler.new(tree TreeNode) Compiler {
	return Compiler{
		tree: tree
	}
}

fn (mut self Compiler) compile() []Bytecode {
	self.compile_walk(self.tree)

	return self.bytecodes
}

fn (mut self Compiler) compile_walk(tree TreeNode) {
	if tree is Expr {
		match tree {
			BinOp {
				self.compile_bin_op(tree)
			}
			UnaryOp {
				self.compile_unary_op(tree)
			}
			Number {
				self.compile_number(tree)
			}
		}
	}
}

fn (mut self Compiler) compile_bin_op(tree BinOp) {
	self.compile_walk(tree.left)
	self.compile_walk(tree.right)

	self.bytecodes << Bytecode{BytecodeType.bin_op, tree.operator}
}

fn (mut self Compiler) compile_unary_op(tree UnaryOp) {
	self.compile_walk(tree.value)

	self.bytecodes << Bytecode{BytecodeType.unary_op, tree.operator}
}

fn (mut self Compiler) compile_number(tree Number) {
	self.bytecodes << Bytecode{BytecodeType.push, tree}
}

fn (mut self Compiler) iter() Compiler {
	return self
}

fn (mut self Compiler) next() ?Bytecode {
	if self.bytecode_index < self.bytecodes.len {
		bytecode := self.bytecodes[self.bytecode_index]

		self.bytecode_index += 1

		return bytecode
	}

	return none
}
