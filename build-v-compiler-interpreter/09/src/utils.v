module main

// import v.reflection

struct CodeResult[T] {
	code     string
	expected T
}

struct OperatorJumpTypes {
	operator  string
	jump_type BytecodeType
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
						print_ast(Expr(target), depth + 2)
						println(',')
					}
					println('${indent}    ],')
					print_ast(tree.value, depth + 1)
					print(',\n${indent})')
				}
				Conditional {
					println('\n${indent}${typeof(tree).name}(')
					print_ast(tree.condition, depth + 1)
					println(',')
					print_ast(tree.body, depth + 1)
					println(',')
					print('${indent})')
				}
			}
		}
		Body {
			print('${indent}${typeof(tree).name}([')
			for statement in tree.statements {
				print_ast(statement, depth + 1)
				print(',')
			}
			print('\n${indent}])')
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
				BoolOp {
					panic('Unimplemented BoolOp in utils.print_ast/2')
				}
				Constant {
					constant_value := tree.value
					match constant_value {
						int {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
						f32 {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
						bool {
							print('${indent}${typeof(tree).name}(${tree.value})')
						}
					}
				}
				Variable {
					print('${indent}${typeof(tree).name}(${tree.name})')
				}
			}
		}
	}
}
