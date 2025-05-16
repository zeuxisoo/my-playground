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
					println('\n${indent}${typeof(tree).name}(')
					print_ast(tree.expr, depth + 1)
					print(',\n${indent})')
				}
				Assignment {
					println('\n${indent}${typeof(tree).name}(')
					println('${indent}    [')
					for target in tree.targets {
						print_ast(Expr(Value(target)), depth + 2)
						println(',')
					}
					println('${indent}    ],')
					print_ast(tree.value, depth + 1)
					print(',\n${indent})')
				}
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
				Value {
					match tree {
						Int {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
						Float {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
						Variable {
							print('${indent}${typeof(tree).name}(${tree.name})')
						}
					}
				}
			}
		}
	}
}
