module main

fn main() {
	input := '(add 2 (sub 4 3))'
	output := compile(input)

	println('input : ${input}')
	println('output: ${output}')
}
