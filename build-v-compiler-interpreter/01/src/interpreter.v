module main

import datatypes { Stack }

struct Interpreter {
mut:
	stack    Stack[int]
	bytecode []Bytecode
	ptr      int
}

fn Interpreter.new(bytecode []Bytecode) Interpreter {
	return Interpreter{
		stack: Stack[int]{}
		bytecode: bytecode
		ptr: 0
	}
}

fn (mut self Interpreter) interpret() !int {
	for bytecode in self.bytecode {
		if bytecode.kind == BytecodeType.push {
			self.stack.push(bytecode.value.int())
		} else if bytecode.kind == BytecodeType.bin_op {
			right := self.stack.pop()!
			left := self.stack.pop()!

			result := match bytecode.value {
				'+' {
					left + right
				}
				'-' {
					left - right
				}
				else {
					return error('Unknown operator ${bytecode.value}.')
				}
			}

			self.stack.push(result)
		}
	}

	return self.stack.pop()!
}
