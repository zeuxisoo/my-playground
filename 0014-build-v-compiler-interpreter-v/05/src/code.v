module main

type BytecodeValue = Number | string

enum BytecodeType {
	bin_op
	unary_op
	push
	pop
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
