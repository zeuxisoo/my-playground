module main

struct Input {
mut:
	pos   int
	line  int
	col   int
	input []rune
}

fn Input.new(input string) Input {
	return Input{
		pos:   0
		line:  0
		col:   0
		input: input.runes()
	}
}

pub fn (mut i Input) next() rune {
	ch := i.input[i.pos]

	i.pos = i.pos + 1

	if ch == `\n` {
		i.line++
		i.col = 0
	} else {
		i.col++
	}

	return ch
}

pub fn (i Input) peek() ?rune {
	return i.input[i.pos] or { none }
}

pub fn (i Input) eof() bool {
	return i.peek() == none
}

pub fn (i Input) croak(msg string) IError {
	return error('${msg} (${i.line}:${i.col})')
}
