module main

import datatypes { Stack }
import math

@[heap]
struct Interpreter {
mut:
	stack             Stack[BytecodeValue]
	scope             map[string]BytecodeValue
	bytecodes         []Bytecode
	ptr               int
	last_value_popped BytecodeValue
}

fn Interpreter.new(bytecode []Bytecode) Interpreter {
	return Interpreter{
		stack: Stack[BytecodeValue]{}
		scope: map[string]BytecodeValue{}
		bytecodes: bytecode
		ptr: 0
	}
}

fn (mut self Interpreter) interpret() !BytecodeValue {
	for self.ptr < self.bytecodes.len {
		bytecode := self.bytecodes[self.ptr]
		bytecode_name := bytecode.kind

		bytecode_methods := {
			BytecodeType.bin_op:            self.interpret_bin_op
			BytecodeType.unary_op:          self.interpret_unary_op
			BytecodeType.push:              self.interpret_push
			BytecodeType.pop:               self.interpret_pop
			BytecodeType.save:              self.interpret_save
			BytecodeType.load:              self.interpret_load
			BytecodeType.copy:              self.interpret_copy
			BytecodeType.pop_jump_if_false: self.interpret_pop_jump_if_false
		}

		if bytecode_name in bytecode_methods {
			method := bytecode_methods[bytecode_name]
			method(bytecode)!
		} else {
			return error('Unknown bytecode function ${bytecode_name}')
		}
	}

	return self.last_value_popped
}

fn (mut self Interpreter) interpret_bin_op(bytecode Bytecode) ! {
	// tail first
	right := self.stack.pop()! as Constant
	left := self.stack.pop()! as Constant
	operator := bytecode.value as string

	mut result := unsafe { BytecodeValue(Constant{0}) }

	// int + int
	if left.value is int && right.value is int {
		result = self.interpret_compuation[int, int](operator, left.value, right.value)!
	}

	// int + float
	if left.value is int && right.value is f32 {
		result = self.interpret_compuation[int, f32](operator, left.value, right.value)!
	}

	// float + int
	if left.value is f32 && right.value is int {
		result = self.interpret_compuation[f32, int](operator, left.value, right.value)!
	}

	// float + float
	if left.value is f32 && right.value is f32 {
		result = self.interpret_compuation[f32, f32](operator, left.value, right.value)!
	}

	self.stack.push(result)

	self.ptr += 1
}

fn (mut self Interpreter) interpret_unary_op(bytecode Bytecode) ! {
	operator := bytecode.value as string
	constant := self.stack.pop()! as Constant
	constant_value := constant.value

	mut result := unsafe { BytecodeValue(Constant{0}) }

	if constant_value is int {
		if operator == '+' {
			result = Constant{constant_value}
		}

		if operator == '-' {
			result = Constant{constant_value * -1}
		}

		if operator == 'not' { // not less and equals to zero
			result = Constant{constant_value <= 0}
		}
	}

	if constant_value is f32 {
		if operator == '+' {
			result = Constant{constant_value}
		}

		if operator == '-' {
			result = Constant{constant_value * -1}
		}

		if operator == 'not' { // not less and equals to zero
			result = Constant{constant_value <= 0}
		}
	}

	if constant_value is bool {
		// +true: 1
		// +false: 0
		if operator == '+' {
			result = Constant{int(constant_value)}
		}

		// -true: -1
		// -false: 0
		if operator == '-' {
			result = Constant{int(constant_value) * -1}
		}

		if operator == 'not' {
			result = Constant{!bool(constant_value)}
		}
	}

	self.stack.push(result)

	self.ptr += 1
}

fn (mut self Interpreter) interpret_push(bytecode Bytecode) ! {
	self.stack.push(bytecode.value)

	self.ptr += 1
}

fn (mut self Interpreter) interpret_pop(bytecode Bytecode) ! {
	self.last_value_popped = self.stack.pop()!

	self.ptr += 1
}

fn (mut self Interpreter) interpret_save(bytecode Bytecode) ! {
	name := bytecode.value as string

	self.scope[name] = self.stack.pop()!

	self.ptr += 1
}

fn (mut self Interpreter) interpret_load(bytecode Bytecode) ! {
	bytecode_value := bytecode.value

	saved_name := match bytecode_value {
		Constant {
			contant_value := bytecode_value.value

			match contant_value {
				int {
					bytecode_value.value.str()
				}
				f32 {
					bytecode_value.value.str()
				}
				bool {
					bytecode_value.value.str()
				}
			}
		}
		Variable {
			bytecode_value.name
		}
		string {
			bytecode_value
		}
	}

	self.stack.push(self.scope[saved_name]!)

	self.ptr += 1
}

fn (mut self Interpreter) interpret_copy(bytecode Bytecode) ! {
	bytecode_value := self.stack.peek()!

	self.stack.push(bytecode_value)

	self.ptr += 1
}

fn (mut self Interpreter) interpret_pop_jump_if_false(bytecode Bytecode) ! {
	bytecode_condition_value := self.stack.pop()!

	bytecode_condition_value_falsely := match bytecode_condition_value {
		Constant {
			contant_value := bytecode_condition_value.value

			match contant_value {
				int {
					contant_value != 0
				}
				f32 {
					contant_value != f32(0)
				}
				bool {
					contant_value != false
				}
			}
		}
		Variable {
			bytecode_condition_value.name != ''
		}
		string {
			bytecode_condition_value != ''
		}
	}

	if !bytecode_condition_value_falsely {
		bytecode_pop_jump_value := bytecode.value

		position := (bytecode_pop_jump_value as string).int()

		/*
		position := match bytecode_pop_jump_value {
			Value {
				match bytecode_pop_jump_value {
					Int {
						bytecode_pop_jump_value.value
					}
					Float {
						return error('Cannot pop_jump_if_false float ${bytecode_pop_jump_value.value}.')
					}
					Variable {
						return error('Cannot pop_jump_if_false variable ${bytecode_pop_jump_value.name}.')
					}
				}
			}
			string {
				bytecode_pop_jump_value.int()
			}
		}
		*/

		self.ptr += position
	} else {
		self.ptr += 1
	}
}

fn (mut self Interpreter) interpret_compuation[L, R](operator string, left L, right R) !BytecodeValue {
	result := match operator {
		'+' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Constant{
					value: f32(1) * (left + right)
				}
			} else {
				Constant{
					value: int(left + right)
				}
			}
		}
		'-' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Constant{
					value: f32(1) * (left - right)
				}
			} else {
				Constant{
					value: int(left - right)
				}
			}
		}
		'*' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Constant{
					value: f32(1) * (left * right)
				}
			} else {
				Constant{
					value: int(left * right)
				}
			}
		}
		'/' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Constant{
					value: f32(1) * (left / right)
				}
			} else {
				Constant{
					value: int(left / right)
				}
			}
		}
		'%' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				Constant{
					value: f32(math.fmod(left, right))
				}
			} else {
				Constant{
					value: int(int(left) % int(right))
				}
			}
		}
		'**' {
			Constant{
				value: math.powf(left, right)
			}
		}
		else {
			return error('Unknown compuation operator ${operator}.')
		}
	}

	return BytecodeValue(result)
}

fn (self Interpreter) get_scope() map[string]BytecodeValue {
	return self.scope
}
