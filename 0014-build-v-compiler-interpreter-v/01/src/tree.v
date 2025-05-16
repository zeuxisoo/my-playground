module main

type TreeNode = BinOp | Int

struct BinOp {
	operator string
	left     Int
	right    Int
}

struct Int {
	value int
}
