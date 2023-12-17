module main

struct CodeResult[T] {
	code     string
	expected T
}

fn print_ast(tree TreeNode, depth int) {
	ident := '    '.repeat(depth)

	match tree {
		BinOp {
			println('${ident}${tree.operator}')
			print_ast(tree.left, depth + 1)
			print_ast(tree.right, depth + 1)
		}
		Number {
			match tree {
				Int {
					println('${ident}${tree.value}')
				}
				Float {
					println('${ident}${tree.value}')
				}
			}
		}
	}
}
