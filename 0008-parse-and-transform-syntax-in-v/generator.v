module generator

import transformer as trans

pub fn generate(node trans.AstNode) string {
	result := match node {
		trans.ProgramNode {
			// 1.
			// node.body.map(fn(child trans.AstNode) string {
			// 	return generate(child)
			// }).join('')

			// 2.
			// node.body.map(generate(it)).join('')

			// 3.
			mut code := ''

			for child in node.body {
				code += generate(child)
			}

			code
		}
		trans.ExpressionStatementNode {
			generate(node.expression)
		}
		trans.CallExpressionNode {
			callee := generate(node.callee)

			// 1.
			// arguments := node.arguments.map(fn(argument trans.AstNode) string {
			// 	return generate(argument)
			// })

			// 2.
			// arguments := node.arguments.map(generate(it))

			// 3.
			mut arguments := []string{}

			for argument in node.arguments {
				arguments << generate(argument)
			}

			// return
			'${callee}(${arguments.join(', ')})'
		}
		trans.NumberNode {
			node.value
		}
		trans.IdentifierNode {
			node.name
		}
	}

	return result
}
