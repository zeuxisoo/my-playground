module main

//
type Node = Program
	| MoveRight
	| MoveLeft
	| Increment
	| Decrement
	| Look
	| ReadByte
	| While

//
struct Program {
mut:
	nodes []&Node
}

fn new_program(nodes []&Node) &Program {
	return &Program{ nodes }
}

//
struct MoveRight {
}

fn new_move_right() &MoveRight {
	return &MoveRight{}
}

//
struct MoveLeft {
}

fn new_move_left() &MoveLeft {
	return &MoveLeft{}
}

//
struct Increment {
}

fn new_increment() &Increment {
	return &Increment{}
}

//
struct Decrement {
}

fn new_decrement() &Decrement {
	return &Decrement{}
}

//
struct Look {
}

fn new_look() &Look {
	return &Look{}
}

//
struct ReadByte {
}

fn new_read_byte() &ReadByte {
	return &ReadByte{}
}

//
struct While {
	nodes []&Node
}

fn new_while(nodes []&Node) &While {
	return &While{ nodes }
}
