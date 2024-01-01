module main

type BytecodeValue = Value | string

enum BytecodeType {
	bin_op
	unary_op
	push
	pop
	save
	load
	copy
}

fn (self BytecodeType) str_full() string {
	return '${typeof(self).name}.${self}'
}

struct Bytecode {
	kind  BytecodeType
	value BytecodeValue
}

fn (self Bytecode) str() string {
	return "Bytecode(${self.kind.str_full()}, '${self.value}')"
}
