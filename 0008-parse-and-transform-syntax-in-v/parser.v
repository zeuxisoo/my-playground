module parser

import tokenizer { Token }

//
pub type AstNode = ExpressionNode | NumberNode | ProgramNode

pub struct ProgramNode {
pub:
	kind string
pub mut:
	body []AstNode
}

pub struct NumberNode {
pub:
	kind  string
	value string
}

pub struct ExpressionNode {
pub:
	kind string
	name string
pub mut:
	params []AstNode
}

//
pub fn parse(tokens []Token) AstNode {
	mut program := ProgramNode{
		kind: 'Program'
		body: []AstNode{}
	}

	node, _ := walk(tokens, 0)

	program.body << node

	return program
}

fn walk(tokens []Token, index int) (AstNode, int) {
	mut current := index
	mut token := tokens[current]

	if token.kind == 'number' {
		current = current + 1

		return NumberNode{
			kind: 'NumberLiteral'
			value: token.value
		}, current
	}

	if token.kind == 'paren' && token.value == '(' {
		current = current + 1
		token = tokens[current]

		mut expression := ExpressionNode{
			kind: 'CallExpression'
			name: token.value
			params: []AstNode{}
		}

		current = current + 1
		token = tokens[current]

		for token.value != ')' {
			node, new_current := walk(tokens, current)

			expression.params << node
			current = new_current

			token = tokens[current]
		}

		current = current + 1

		return expression, current
	}

	panic('Unknown token: `${token.kind}`')
}
