module main

type TreeNode = Expr | MaybeStmt
type Expr = BinOp | Number | UnaryOp
type MaybeStmt = f32 | int | string
type Number = Float | Int

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
