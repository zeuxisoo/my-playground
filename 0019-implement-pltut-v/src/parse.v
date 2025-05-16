module main

//
type Expression = AssignExpression
	| BinaryExpression
	| BoolExpression
	| CallExpression
	| IfExpression
	| LambdaExpression
	| LetExpression
	| NumExpression
	| Program
	| StrExpression
	| VarDefExpression
	| VarExpression
type FalseOrTokenValue = TokenValue | bool
type Parser = fn () Expression

//
const precedence = {
	'=':  1
	'||': 2
	'&&': 3
	'<':  7
	'>':  7
	'<=': 7
	'>=': 7
	'==': 7
	'!=': 7
	'+':  10
	'-':  10
	'*':  20
	'/':  20
	'%':  20
}

//
enum ExpressionKind {
	prog
	call
	assign
	binary
	@if
	bool
	lambda
	var
	vardef
	let
	num
	str
}

//
struct Program {
	kind ExpressionKind
	prog []Expression
}

//
struct CallExpression {
	kind ExpressionKind
	func Expression
	args []Expression
}

struct AssignExpression {
	kind     ExpressionKind
	operator string
	left     Expression
	right    Expression
}

struct BinaryExpression {
	kind     ExpressionKind
	operator string
	left     Expression
	right    Expression
}

struct IfExpression {
	kind ExpressionKind
	cond Expression
	then Expression
mut:
	@else ?Expression
}

struct BoolExpression {
	kind  ExpressionKind
	value bool
}

struct LambdaExpression {
	kind ExpressionKind
	name ?string
	vars []Expression
	body Expression
}

struct VarExpression {
	kind  ExpressionKind
	value string
}

struct VarDefExpression {
	kind ExpressionKind
	name Expression
	def  ?Expression
}

struct LetExpression {
	kind ExpressionKind
	vars []Expression
	body Expression
}

struct NumExpression {
	kind  ExpressionKind
	value string
}

struct StrExpression {
	kind  ExpressionKind
	value string
}

//
struct Parse {
mut:
	token Token
}

fn Parse.new(token Token) Parse {
	return Parse{
		token: token
	}
}

pub fn (mut p Parse) parse_top_level() Expression {
	mut prog := []Expression{}

	for !p.token.eof() {
		prog << p.parse_expression()

		if !p.token.eof() {
			p.skip_punc(`;`)
		}
	}

	return Program{
		kind: .prog
		prog: prog
	}
}

fn (mut p Parse) parse_expression() Expression {
	return p.maybe_call(fn [mut p] () ?Expression {
		return p.maybe_binary(p.parse_atom(), 0)
	})
}

fn (mut p Parse) parse_atom() Expression {
	return p.maybe_call(fn [mut p] () ?Expression {
		if p.is_punc(`(`) {
			p.token.next()

			exp := p.parse_expression()

			p.skip_punc(`)`)

			return exp
		}

		if p.is_punc(`{`) {
			return p.parse_prog()
		}

		if p.is_kw('let') {
			return p.parse_let()
		}

		if p.is_kw('if') {
			return p.parse_if()
		}

		if p.is_kw('true') || p.is_kw('false') {
			return p.parse_bool()
		}

		if p.is_kw('lambda') || p.is_kw('λ') {
			p.token.next()

			return p.parse_lambda()
		}

		tok := p.token.next()?

		if tok.kind == .var {
			return VarExpression{
				kind:  .var
				value: tok.value
			}
		}

		if tok.kind == .num {
			return NumExpression{
				kind:  .num
				value: tok.value
			}
		}

		if tok.kind == .str {
			return StrExpression{
				kind:  .str
				value: tok.value
			}
		}

		p.unexpected()

		panic('Unexpected token: `${tok.value}`')
	})
}

fn (mut p Parse) parse_prog() Expression {
	prog := p.delimited(`{`, `}`, `;`, unsafe { p.parse_expression })

	if prog.len == 0 {
		return Program{
			kind: .prog
			prog: []Expression{}
		}
	}

	if prog.len == 1 {
		return prog[0]
	}

	return Program{
		kind: .prog
		prog: prog
	}
}

fn (mut p Parse) parse_if() IfExpression {
	p.skip_kw('if')

	cond := p.parse_expression()

	if !p.is_punc(`{`) {
		p.skip_kw('then')
	}

	then := p.parse_expression()

	mut expression := IfExpression{
		kind: .@if
		cond: cond
		then: then
	}

	if p.is_kw('else') {
		p.token.next()
		expression.@else = p.parse_expression()
	}

	return expression
}

fn (mut p Parse) parse_bool() BoolExpression {
	tok := p.token.next() or { panic('Expecting bool') }

	return BoolExpression{
		kind:  .bool
		value: tok.value == 'true'
	}
}

fn (mut p Parse) parse_lambda() LambdaExpression {
	peek_tok := p.token.peek() or { panic('Expecting peek token for lambda') }

	return LambdaExpression{
		kind: .lambda
		name: if peek_tok.kind == .var {
			name := p.token.next() or { panic('Expecting variable for lamdba') }
			name.value
		} else {
			none
		}
		vars: p.delimited(`(`, `)`, `,`, unsafe { p.parse_varname })
		body: p.parse_expression()
	}
}

fn (mut p Parse) parse_call(func Expression) Expression {
	return CallExpression{
		kind: .call
		func: func
		args: p.delimited(`(`, `)`, `,`, unsafe { p.parse_expression })
	}
}

fn (mut p Parse) parse_varname() Expression {
	name := p.token.next() or { panic('Expecting variable name') }

	if name.kind != .var {
		p.token.croak('Expecting variable name')
	}

	return VarExpression{
		kind:  .var
		value: name.value
	}
}

fn (mut p Parse) parse_let() Expression {
	p.skip_kw('let')

	peek_tok := p.token.peek() or { panic('Expecting peek token for let') }

	if peek_tok.kind == .var {
		tok := p.token.next() or { panic('Expecting variable for let') }

		name := tok.value
		defs := p.delimited(`(`, `)`, `,`, unsafe { p.parse_vardef })

		mut vars := []Expression{}
		mut args := []Expression{}
		for def in defs {
			var_def := def as VarDefExpression

			vars << var_def.name
			args << var_def.def or {
				BoolExpression{
					kind:  .bool
					value: false
				}
			}
		}

		return CallExpression{
			kind: .call
			func: LambdaExpression{
				kind: .lambda
				name: name
				vars: vars
				body: p.parse_expression()
			}
			args: args
		}
	}

	return LetExpression{
		kind: .let
		vars: p.delimited(`(`, `)`, `,`, unsafe { p.parse_vardef })
		body: p.parse_expression()
	}
}

fn (mut p Parse) parse_vardef() Expression {
	name := p.parse_varname()

	return match p.is_op('=') {
		bool { // false
			VarDefExpression{
				kind: .vardef
				name: name
				def:  none
			}
		}
		TokenValue {
			p.token.next() or { panic('Expecting variable definition') }

			VarDefExpression{
				kind: .vardef
				name: name
				def:  p.parse_expression()
			}
		}
	}
}

//
fn (mut p Parse) skip_punc(ch u8) {
	if p.is_punc(ch) {
		p.token.next()
	} else {
		p.token.croak('Expecting punctuation: "${ch}"')
	}
}

fn (mut p Parse) skip_kw(kw string) {
	if p.is_kw(kw) {
		p.token.next()
	} else {
		p.token.croak('Expecting keyword: "${kw}"')
	}
}

/* not in use
fn (mut p Parse) skip_op(op string) {
	match p.is_op(op) {
		bool { // false
			p.token.croak('Expecting operator: "${op}"')
		}
		TokenValue {
			p.token.next()
		}
	}
}
*/

fn (mut p Parse) maybe_call(expr fn () ?Expression) Expression {
	expression := expr() or { panic(err) }

	return if p.is_punc(`(`) {
		p.parse_call(expression)
	} else {
		expression
	}
}

fn (mut p Parse) maybe_binary(left Expression, my_prec int) Expression {
	tok := p.is_op(none)

	return match tok {
		bool { // false
			left
		}
		TokenValue {
			his_prec := precedence[tok.value]

			if his_prec > my_prec {
				p.token.next()

				if tok.value == '=' {
					p.maybe_binary(AssignExpression{
						kind:     .assign
						operator: tok.value
						left:     left
						right:    p.maybe_binary(p.parse_atom(), his_prec)
					}, my_prec)
				} else {
					p.maybe_binary(BinaryExpression{
						kind:     .binary
						operator: tok.value
						left:     left
						right:    p.maybe_binary(p.parse_atom(), his_prec)
					}, my_prec)
				}
			} else {
				left
			}
		}
	}
}

fn (mut p Parse) delimited(start u8, stop u8, separator u8, parser Parser) []Expression {
	mut expression := []Expression{}
	mut first := true

	p.skip_punc(start)

	for !p.token.eof() {
		if p.is_punc(stop) {
			break
		}

		if first {
			first = false
		} else {
			p.skip_punc(separator)
		}

		if p.is_punc(stop) {
			break
		}

		expression << parser()
	}

	p.skip_punc(stop)

	return expression
}

//
fn (mut p Parse) is_punc(ch u8) bool {
	tok := p.token.peek() or { return false }

	return tok.kind == .punc && tok.value == ch.ascii_str()
}

fn (mut p Parse) is_kw(kw string) bool {
	tok := p.token.peek() or { return false }

	return tok.kind == .kw && tok.value == kw
}

fn (mut p Parse) is_op(op ?string) FalseOrTokenValue {
	tok := p.token.peek() or { return false }

	if tok.kind == .op {
		if op == none {
			return tok
		}
		if tok.value == op or { return false } {
			return tok
		}
	}

	return false
}

fn (mut p Parse) unexpected() {
	tok := p.token.peek() or { panic('Unknown error: ${err}') }

	p.token.croak('Unexpected token: ${tok}')
}
