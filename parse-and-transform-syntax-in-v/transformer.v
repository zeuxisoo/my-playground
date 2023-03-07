module transformer

import parser

//
type TraverseNode = AstNode | []AstNode

type AstNode = CallExpressionNode
	| ExpressionStatementNode
	| IdentifierNode
	| NumberNode
	| ProgramNode

struct ProgramNode {
	kind string
pub mut:
	body []AstNode
}

struct NumberNode {
	kind string
pub:
	value string
}

struct IdentifierNode {
	kind string
pub:
	name string
}

struct CallExpressionNode {
	kind string
pub:
	callee IdentifierNode
pub mut:
	arguments []AstNode
}

struct ExpressionStatementNode {
	kind string
pub:
	expression AstNode
}

//
pub fn transform(ast parser.AstNode) AstNode {
	mut new_ast := ProgramNode{
		kind: 'Program'
	}

	new_ast.body << traverse(ast) as []AstNode

	return new_ast
}

fn traverse(ast parser.AstNode) TraverseNode {
	match ast {
		parser.ProgramNode {
			mut nodes := []AstNode{}

			for node in ast.body {
				mut expression := traverse(node) as AstNode

				if node is parser.ExpressionNode {
					expression = AstNode(ExpressionStatementNode{
						kind: 'ExpressionStatement'
						expression: expression
					})
				}

				nodes << expression
			}

			return nodes
		}
		parser.ExpressionNode {
			mut expression := CallExpressionNode{
				kind: 'CallExpression'
				callee: IdentifierNode{
					kind: 'Identifier'
					name: ast.name
				}
			}

			for node in ast.params {
				expression.arguments << traverse(node) as AstNode
			}

			return AstNode(expression)
		}
		parser.NumberNode {
			return AstNode(NumberNode{
				kind: 'NumberLiteral'
				value: ast.value
			})
		}
	}
}
