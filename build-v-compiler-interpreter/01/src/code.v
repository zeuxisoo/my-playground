module main

enum BytecodeType {
	bin_op
	push
}

struct Bytecode {
	kind  BytecodeType
	value string
}
