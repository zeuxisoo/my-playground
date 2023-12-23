module main

fn test_print_ast() {
	mut tokenizer := Tokenizer.new('3 + 5')
	mut tokens := tokenizer.tokenize()!
	mut parser := Parser.new(tokens)
	mut tree := parser.parse()!

	print_ast(tree, 0)

	assert true
}
