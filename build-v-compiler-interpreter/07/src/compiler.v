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
			Assignment {
				self.compile_assignment(tree)
			}
			Conditional {
				self.compile_conditional(tree)
			}
		}
	}

	if tree is Body {
		self.compile_body(tree)
	}

	if tree is Expr {
		match tree {
			BinOp {
				self.compile_bin_op(tree)
			}
			UnaryOp {
				self.compile_unary_op(tree)
			}
			Value {
				match tree {
					Int {
						self.compile_int(tree)
					}
					Float {
						self.compile_float(tree)
					}
					Variable {
						self.compile_variable(tree)
					}
				}
			}
		}
	}
}

fn (mut self Compiler) compile_program(program Program) {
	for statement in program.statements {
		self.compile_walk(statement)
	}
}

fn (mut self Compiler) compile_body(body Body) {
	for statement in body.statements {
		self.compile_walk(statement)
	}
}

fn (mut self Compiler) compile_expr_statement(expr_statement ExprStatement) {
	self.compile_walk(expr_statement.expr)

	self.bytecodes << Bytecode{BytecodeType.pop, 'pop'}
}

fn (mut self Compiler) compile_assignment(assignment Assignment) {
	self.compile_walk(assignment.value)

	for target in assignment.targets#[..-1] {
		self.bytecodes << Bytecode{BytecodeType.copy, 'copy'}
		self.bytecodes << Bytecode{BytecodeType.save, target.name}
	}

	self.bytecodes << Bytecode{BytecodeType.save, assignment.targets.last().name}
}

fn (mut self Compiler) compile_conditional(conditional Conditional) {
	// parse condition
	self.compile_walk(conditional.condition)

	// placeholder for bytecode pop_jump_if_false
	self.bytecodes << Bytecode{BytecodeType.pop_jump_if_false, '0'}

	// current bytecode array size
	old_bytecode_length := self.bytecodes.len

	// parse condition body
	self.compile_walk(conditional.body)

	// new bytecode array size = current + parsed
	new_bytecode_length := self.bytecodes.len

	// diff body bytecode array size = new bytecode array size - current/old bytecode array size
	body_bytecode_length := new_bytecode_length - old_bytecode_length

	// update placeholder bytecode pop_jump_if_false with jump target index
	pop_jump_if_false_index := old_bytecode_length - 1
	pop_jump_target_index := body_bytecode_length + 1

	self.bytecodes[pop_jump_if_false_index] = Bytecode{
		kind: BytecodeType.pop_jump_if_false
		value: pop_jump_target_index.str()
	}
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

fn (mut self Compiler) compile_int(value Value) {
	self.bytecodes << Bytecode{BytecodeType.push, value}
}

fn (mut self Compiler) compile_float(value Value) {
	self.bytecodes << Bytecode{BytecodeType.push, value}
}

fn (mut self Compiler) compile_variable(value Value) {
	self.bytecodes << Bytecode{BytecodeType.load, value}
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
