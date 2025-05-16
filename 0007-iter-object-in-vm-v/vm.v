module main

// Opcode
enum Opcode {
	load_const
	load_local
	store_global
	store_local
	get_iter
	for_iter
	pop_top
	build_list
	append_list
	call_function
	jump_absolute
}

// Object
type Object = IntObject | IterObject | ListObject

struct IntObject {
	value int
}

struct ListObject {
mut:
	value []Object
}

struct IterObject {
	value Object
mut:
	index int
}

fn (mut iter IterObject) next() Object {
	list_object := iter.value as ListObject

	mut object := unsafe { Object{} }

	if iter.index < list_object.value.len {
		object = list_object.value[iter.index]
	}

	iter.index = iter.index + 1

	return object
}

// Instruction
struct Instruction {
	filename string
	line     int
	column   int
	opcode   Opcode
	operand1 int
	operand2 int
	operand3 int
}

// Bytecode
struct Bytecode {
	constants    []Object
	names        []string
	instructions []Instruction
}

fn new_bytecode(constants []Object, names []string, instructions []Instruction) &Bytecode {
	return &Bytecode{constants, names, instructions}
}

// VM
struct VM {
mut:
	stack   []Object
	globals map[string]Object
	locals  map[string]Object
}

fn new_vm() &VM {
	return &VM{
		stack: []Object{}
		globals: map[string]Object{}
		locals: map[string]Object{}
	}
}

fn (mut vm VM) push(object Object) {
	vm.stack << object
}

fn (mut vm VM) pop() Object {
	return vm.stack.pop()
}

fn (vm VM) peek() Object {
	return vm.stack.last()
}

fn (vm VM) peek_at_last(position int) Object {
	return vm.stack[vm.stack.len - position]
}

fn (mut vm VM) add_globals(name string, object Object) {
	vm.globals[name] = object
}

fn (mut vm VM) add_locals(name string, object Object) {
	vm.locals[name] = object
}

fn (mut vm VM) run(bytecode Bytecode) {
	mut i := 0

	for i < bytecode.instructions.len {
		instruction := bytecode.instructions[i]

		match instruction.opcode {
			.load_const {
				vm.push(bytecode.constants[instruction.operand3])
			}
			.load_local {
				variable_name := bytecode.names[instruction.operand3]
				variable_value := vm.locals[variable_name] or {
					panic('vm.run: cannot find the variable name in locals table, got `${variable_name}`')
				}

				vm.push(variable_value)
			}
			.store_global {
				variable_name := bytecode.names[instruction.operand3]

				vm.add_globals(variable_name, vm.pop())
			}
			.store_local {
				variable_name := bytecode.names[instruction.operand3]

				vm.add_locals(variable_name, vm.peek())
			}
			.build_list {
				vm.push(ListObject{})
			}
			.append_list {
				object := vm.pop()

				mut list_object := vm.peek_at_last(instruction.operand3) as ListObject
				list_object.value << object
			}
			.call_function {
				// simulation
				mut list_object := ListObject{}

				for j in 0 .. 7 {
					list_object.value << IntObject{
						value: j
					}
				}

				vm.push(list_object)
			}
			.get_iter {
				object := vm.pop()

				vm.push(IterObject{
					value: object
				})
			}
			.for_iter {
				mut object := vm.peek()

				// Must be IterObject to call the next/0 method
				if mut object is IterObject {
					iter_value := object.next()

					if iter_value == unsafe { Object{} } {
						vm.pop()
						i = instruction.operand3
					} else {
						vm.push(iter_value)
					}
				}
			}
			.pop_top {
				vm.pop()
			}
			.jump_absolute {
				i = instruction.operand3
			}
		}

		i++
	}

	dump(i)
	dump(vm.stack)
	dump(vm.globals)
	dump(vm.locals)
}

fn main() {
	println('Hello Iter Object')
	println('-'.repeat(10))

	// vfmt off
	bytecode := new_bytecode(
		// constants
		[IntObject{1}, IntObject{5}, IntObject{10}, IntObject{15}],
		// names
		['temp_a', 'temp_b', 'temp_c', 'for_value', 'result'],
		// instructions
		// temp_a = 1
		// temp_b = 5
		// temp_c = 10
		// result = []
		// for for_value := some_range_function(0, 6) {
		// 	result << for_value
		// }
		[
			Instruction{'test.txt', 1, 1, .load_const, 0, 0, 0},    // stack : [const:int:1]
			Instruction{'test.txt', 1, 1, .store_global, 0, 0, 0},  // gloabl: [temp_a = 1]
			Instruction{'test.txt', 1, 1, .load_const, 0, 0, 1},    // stack : [const:int:5]
			Instruction{'test.txt', 1, 1, .store_global, 0, 0, 1},  // gloabl: [temp_b = 5, temp_a = 1]
			Instruction{'test.txt', 1, 1, .load_const, 0, 0, 2},    // stack : [const:int:10]
			Instruction{'test.txt', 1, 1, .store_global, 0, 0, 2},  // global: [temp_c = 10, temp_b = 5, temp_a = 1]
			Instruction{'test.txt', 1, 1, .build_list, 0, 0, 0},    // stack : [vm:list:[]]
			Instruction{'test.txt', 1, 1, .call_function, 0, 0, 0}, // stack : [vm:list:[0, 1, 2, 3, 4, 5, 6], vm:list:[]]
			Instruction{'test.txt', 1, 1, .get_iter, 0, 0, 0},      // stack : (vm:iter:[0, 1, 2, 3, 4, 5, 6], vm:list:[])

			Instruction{'test.txt', 1, 1, .for_iter, 0, 0, 14},     // stack : (vm:iter:[0].get1ItemPeekFrom2Iter(), vm:iter:[0, 1, 2, 3, 4, 5, 6], vm:list:[])
			Instruction{'test.txt', 1, 1, .store_local, 0, 0, 3},   // local : [for_value = vm:iter:[0].copy()]
			Instruction{'test.txt', 1, 1, .pop_top, 0, 0, 0},       // stack : [vm:iter:[0, 1, 2, 3, 4, 5, 6], vm:list:[]]
			Instruction{'test.txt', 1, 1, .load_local, 0, 0, 3},    // stack : [for_value.expanded(), vm:iter:[0, 1, 2, 3, 4, 5], vm:list:[]] P.S. get variable: for_value from locals -> get value: vm:iter:[0] -> push stack
			Instruction{'test.txt', 1, 1, .append_list, 0, 0, 2},   // stack : (vm:iter:[0, 1, 2, 3, 4, 5, 6], vm:list:[for_value.expanded])

			Instruction{'test.txt', 1, 1, .jump_absolute, 0, 0, 8}, // jump  : instruction 8 (.for_iter) again, .for_iter next is none will break for loop
			Instruction{'test.txt', 1, 1, .store_global, 0, 0, 4},	// gloabl: [result = [vm:list:[1,2,3,4,5,6]], temp_c = 10, temp_b = 5, temp_a = 1]
		]
	)
	// vfmt on

	mut vm := new_vm()
	vm.run(bytecode)
}
