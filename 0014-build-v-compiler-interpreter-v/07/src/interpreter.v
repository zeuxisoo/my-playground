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
	right := self.stack.pop()! as Value
	left := self.stack.pop()! as Value
	operator := bytecode.value as string

	mut result := unsafe { BytecodeValue(Value(Int{0})) }

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

	self.ptr += 1
}

fn (mut self Interpreter) interpret_unary_op(bytecode Bytecode) ! {
	operator := bytecode.value as string
	value := self.stack.pop()! as Value

	mut result := unsafe { BytecodeValue(Value(Int{0})) }

	if value is Int {
		if operator == '+' {
			result = Value(Int{value.value})
		}

		if operator == '-' {
			result = Value(Int{-value.value})
		}
	}

	if value is Float {
		if operator == '+' {
			result = Value(Float{value.value})
		}

		if operator == '-' {
			result = Value(Float{-value.value})
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
		Value {
			match bytecode_value {
				Int {
					bytecode_value.value.str()
				}
				Float {
					bytecode_value.value.str()
				}
				Variable {
					bytecode_value.name
				}
			}
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

	bytecode_condition_value_state := match bytecode_condition_value {
		Value {
			match bytecode_condition_value {
				Int {
					bytecode_condition_value.value != 0
				}
				Float {
					bytecode_condition_value.value != f32(0)
				}
				Variable {
					bytecode_condition_value.name != ''
				}
			}
		}
		string {
			bytecode_condition_value != ''
		}
	}

	if !bytecode_condition_value_state {
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
				Value(Float{
					value: f32(1) * (left + right)
				})
			} else {
				Value(Int{
					value: int(left + right)
				})
			}
		}
		'-' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Value(Float{
					value: f32(1) * (left - right)
				})
			} else {
				Value(Int{
					value: int(left - right)
				})
			}
		}
		'*' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Value(Float{
					value: f32(1) * (left * right)
				})
			} else {
				Value(Int{
					value: int(left * right)
				})
			}
		}
		'/' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				// tricky ensure first value is type of float
				Value(Float{
					value: f32(1) * (left / right)
				})
			} else {
				Value(Int{
					value: int(left / right)
				})
			}
		}
		'%' {
			if typeof(left).name == 'f32' || typeof(right).name == 'f32' {
				Value(Float{
					value: f32(math.fmod(left, right))
				})
			} else {
				Value(Int{
					value: int(int(left) % int(right))
				})
			}
		}
		'**' {
			Value(Float{
				value: math.powf(left, right)
			})
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
