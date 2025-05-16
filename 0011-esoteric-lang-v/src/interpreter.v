module main

struct Interpreter {
mut:
	table       []int
	table_index int
	input       string
	input_index int
	output      string
}

fn new_interpreter() &Interpreter {
	return &Interpreter{
		table: []int{len: 10, init: 0}
		table_index: 0
		input_index: 0
	}
}

fn (mut i Interpreter) interpret(program Node, input string) {
	i.input  = input
	i.output = ''

	for node in (program as Program).nodes {
		i.node(node)
	}
}

fn (mut i Interpreter) node(node Node) {
	match node {
		MoveRight {
			i.table_index = i.table_index + 1
		}
		MoveLeft {
			i.table_index = i.table_index - 1
		}
		Increment {
			current_table := i.table[i.table_index]

			i.table[i.table_index] = if current_table == 255 {
				0
			}else{
				current_table + 1
			}
		}
		Decrement {
			current_table := i.table[i.table_index]

			i.table[i.table_index] = if current_table == 0 {
				255
			}else{
				current_table - 1
			}
		}
		Look {
			i.output = i.output + rune(i.table[i.table_index]).str()
		}
		ReadByte {
			i.table[i.table_index] = i.input[i.input_index]

			i.input_index = i.input_index + 1
		}
		While {
			for true {
				for child in node.nodes {
					i.node(child)
				}

				if i.table[i.table_index] == 0 {
					break
				}
			}
		}
		else {
			dump(node)
		}
	}
}

fn (i Interpreter) result() string {
	return i.output
}
