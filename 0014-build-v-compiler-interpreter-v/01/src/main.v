module main

fn main() {
	mut tokenizer := Tokenizer.new('3 + 5')
	mut tokens := tokenizer.tokenize()!

	mut parser := Parser.new(tokens)
	mut tree := parser.parse()!

	mut compiler := Compiler.new(tree)
	mut bytecodes := compiler.compile()

	mut interpreter := Interpreter.new(bytecodes)
	mut result := interpreter.interpret()!

	println('The result of "3 + 5" is "${result}"')
}
