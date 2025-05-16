module main

fn test_parser() {
	lexer := new_lexer()
	tokens := lexer.tokenise('~> <~ + - look $ [ look ]')!

	mut parser := new_parser()
	program := parser.parse(tokens)!

	expected := &Node(new_program([
		new_move_right(),
		new_move_left(),
		new_increment(),
		new_decrement(),
		new_look(),
		new_read_byte(),
		new_while([
			new_look()
		])
	]))

	assert program is Program
	assert program.str() == expected.str()
}
