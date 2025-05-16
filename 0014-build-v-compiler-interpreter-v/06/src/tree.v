module main

type TreeNode = Expr | Program | Statement
type Statement = Assignment | ExprStatement
type Expr = BinOp | UnaryOp | Value
type Value = Float | Int | Variable

struct Program {
mut:
	statements []Statement
}

struct ExprStatement {
	expr Expr
}

struct Assignment {
	targets []Variable
	value   Expr
}

struct BinOp {
	operator string
	left     Expr
	right    Expr
}

struct UnaryOp {
	operator string
	value    Expr
}

struct Variable {
	name string
}

fn (self Variable) str() string {
	return "Variable('${self.name}')"
}

struct Int {
	value int
}

fn (self Int) str() string {
	return 'Int(${self.value})'
}

struct Float {
	value f32
}

fn (self Float) str() string {
	return 'Float(${self.value})'
}
