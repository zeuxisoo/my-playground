module main

struct CodeResult[T] {
	code     string
	expected T
}

fn print_ast(tree TreeNode, depth int) {
	indent := '    '.repeat(depth)

	match tree {
		Program {
			print('${indent}${typeof(tree).name}([')
			for statement in tree.statements {
				print_ast(statement, depth + 1)
				print(',')
			}
			print('\n${indent}])\n')
		}
		Statement {
			match tree {
				ExprStatement {
					print('\n${indent}${typeof(tree).name}(\n')
					print_ast(tree.expr, depth + 1)
					print(',\n${indent})')
				}
				OtherStatement {}
			}
		}
		Expr {
			match tree {
				BinOp {
					println('${indent}${typeof(tree).name}(\n${indent}    \'${tree.operator}\',')
					print_ast(tree.left, depth + 1)
					println(',')
					print_ast(tree.right, depth + 1)
					print(',\n${indent})')
				}
				UnaryOp {
					println('${indent}${typeof(tree).name}(\n${indent}    \'${tree.operator}\',')
					print_ast(tree.value, depth + 1)
					print(',\n${indent})')
				}
				Number {
					match tree {
						Int {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
						Float {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
					}
				}
			}
		}
	}
}
