module main

type TreeNode = Expr | Program | Statement
type Statement = ExprStatement | OtherStatement
type Expr = BinOp | Number | UnaryOp
type OtherStatement = f32 | int | string
type Number = Float | Int

struct Program {
mut:
	statements []Statement
}

struct ExprStatement {
	expr Expr
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
