module main

struct CodeResult[T] {
	code     string
	expected T
}

fn print_ast(tree TreeNode, depth int) {
	ident := '    '.repeat(depth)

	match tree {
		Expr {
			match tree {
				BinOp {
					println('${ident}${typeof(tree).name}(\n${ident}    ${tree.operator},')
					print_ast(tree.left, depth + 1)
					println(',')
					print_ast(tree.right, depth + 1)
					print(',\n${ident})')
				}
				UnaryOp {
					println('${ident}${typeof(tree).name}(\n${ident}    ${tree.operator},')
					print_ast(tree.value, depth + 1)
					print(',\n${ident})')
				}
				Number {
					match tree {
						Int {
							print('${ident}${typeof(tree).name}(${tree.value})')
						}
						Float {
							print('${ident}${typeof(tree).name}(${tree.value})')
						}
					}
				}
			}
		}
		else {}
	}
}
