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
	if tree is Program {
		self.compile_program(tree)
	}

	if tree is Statement {
		match tree {
			ExprStatement {
				self.compile_expr_statement(tree)
			}
			OtherStatement {}
		}
	}

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

fn (mut self Compiler) compile_program(program Program) {
	for statement in program.statements {
		self.compile_walk(statement)
	}
}

fn (mut self Compiler) compile_expr_statement(expr_statement ExprStatement) {
	self.compile_walk(expr_statement.expr)

	self.bytecodes << Bytecode{BytecodeType.pop, 'pop'}
}

fn (mut self Compiler) compile_bin_op(bin_op BinOp) {
	self.compile_walk(bin_op.left)
	self.compile_walk(bin_op.right)

	self.bytecodes << Bytecode{BytecodeType.bin_op, bin_op.operator}
}

fn (mut self Compiler) compile_unary_op(unary_op UnaryOp) {
	self.compile_walk(unary_op.value)

	self.bytecodes << Bytecode{BytecodeType.unary_op, unary_op.operator}
}

fn (mut self Compiler) compile_number(number Number) {
	self.bytecodes << Bytecode{BytecodeType.push, number}
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
