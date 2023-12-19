module main

import datatypes { Stack }

@[heap]
struct Interpreter {
mut:
	stack     Stack[BytecodeValue]
	bytecodes []Bytecode
	ptr       int
}

fn Interpreter.new(bytecode []Bytecode) Interpreter {
	return Interpreter{
		stack: Stack[BytecodeValue]{}
		bytecodes: bytecode
		ptr: 0
	}
}

fn (mut self Interpreter) interpret() !BytecodeValue {
	for bytecode in self.bytecodes {
		bytecode_name := bytecode.kind

		bytecode_methods := {
			BytecodeType.push:   self.interpret_push
			BytecodeType.bin_op: self.interpret_bin_op
		}

		if bytecode_name in bytecode_methods {
			method2 := bytecode_methods[bytecode_name]
			method2(bytecode)!
		} else {
			return error('Unknown bytecode function ${bytecode_name}')
		}
	}

	return self.stack.pop()!
}

fn (mut self Interpreter) interpret_push(bytecode Bytecode) ! {
	self.stack.push(bytecode.value)
}

fn (mut self Interpreter) interpret_bin_op(bytecode Bytecode) ! {
	// tail first
	right := self.stack.pop()! as Number
	left := self.stack.pop()! as Number
	operator := bytecode.value as string

	mut result := unsafe { BytecodeValue(Number(Int{0})) }

	// int + int
	if left is Int && right is Int {
		result = self.interpret_compuation[int, int](operator, left.value, right.value)!
	}

	// int + float
	if left is Int && right is Float {
		result = self.interpret_compuation[int, f32](operator, left.value, right.value)!
	}

	// float + int
	if left is Float && right is Int {
		result = self.interpret_compuation[f32, int](operator, left.value, right.value)!
	}

	// float + float
	if left is Float && right is Float {
		result = self.interpret_compuation[f32, f32](operator, left.value, right.value)!
	}

	self.stack.push(result)
}

fn (mut self Interpreter) interpret_compuation[L, R](operator string, left L, right R) !BytecodeValue {
	result := match operator {
		'+' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Number(Float{
					value: f32(1) * (left + right)
				})
			} else {
				Number(Int{
					value: int(left + right)
				})
			}
		}
		'-' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Number(Float{
					value: f32(1) * (left - right)
				})
			} else {
				Number(Int{
					value: int(left - right)
				})
			}
		}
		else {
			return error('Unknown compuation operator ${operator}.')
		}
	}

	return BytecodeValue(result)
}
