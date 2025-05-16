module main

type TreeNode = BinOp | Number
type Number = Float | Int

struct BinOp {
	operator string
	left     Number
	right    Number
}

struct Int {
	value int
}

struct Float {
	value f32
}
