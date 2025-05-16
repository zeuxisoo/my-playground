package main

import (
	"fmt"
	"io"
	"os"

	parsec "github.com/prataprc/goparsec"
)

func main() {
	// Keywords
	keywords := map[string]parsec.Parser {
		"let": parsec.Token("let", "LET"),
		"fun": parsec.Token("fun", "FUN"),
	}

	// Identifiers
	ident := parsec.Ident()

	// Symbols
	assign := parsec.Atom("=", "ASSIGN")
	semicolon := parsec.Atom(";", "SEMICOLON")
	leftParen := parsec.Atom("(", "LEFT_PAREN")
	rightParen := parsec.Atom(")", "RIGHT_PAREN")
	leftBrace := parsec.Atom("{", "LEFT_BRACE")
	rightBrace := parsec.Atom("}", "RIGHT_BRACE")
	leftBracket := parsec.Atom("[", "LEFT_BRACKET")
	rightBracket := parsec.Atom("]", "RIGHT_BRACKET")
	comma := parsec.Atom(",", "COMMA")
	colon := parsec.Atom(":", "COLON")

	// String make it to be a terminal
	strings := (func() parsec.Parser {
		return func(s parsec.Scanner) (parsec.ParsecNode, parsec.Scanner) {
			str, _ := parsec.String()(s)

			if str == nil {
				return nil, s
			}

			return parsec.NewTerminal("STRING", str.(string), s.GetCursor()), s
		}
	})()

	// Numbers
	integer := parsec.Int()
	float := parsec.Float()
	number := parsec.OrdChoice(
		func(ns []parsec.ParsecNode) parsec.ParsecNode {
			terminal := ns[0].(*parsec.Terminal)

			switch terminal.Name {
			case "INT":
				return ns[0]
			case "FLOAT":
				return ns[0]
			}

			return nil
		},
		float,
		integer,
	)

	// Scanner
	scanner := parsec.NewScanner([]byte(`
		let a = 1;
		let b = 2.2;
		let c = "3";
		let d = fun() {}
		let e = fun(a, b, c) {}
		let f = fun(a, b, c) {
			let f1 = 1
			let f2 = 2.2
			let f3 = "3"
		}
		let g = []
		let h = [1, 2.2, "3", fun() {}]
		let i = {}
		let j = { "a": 1, "b": 2.2, "c": "3", "d": fun() {} }
		let k = d()
		let l = d(a, b, c);

		d()
		d(a, b, c)
	`))

	fmt.Println(scanner)

	// Ast
	var statements, value parsec.Parser

	ast := parsec.NewAST("program", 100)

	// Ast array ->
	// item -> value | value "," value
	// list -> "[" item "]"
	array := ast.Kleene("array", nil, &value, comma)
	arrayList := ast.And(
		"arrayList",
		nil,
		leftBracket, array, rightBracket,
	)

	// Ast hash
	// item -> key ":" value | key ":" value ","
	// list -> "{" item "}"
	hash := ast.Kleene("hash", nil, ast.And("hashItem", nil, strings, colon, &value), comma)
	hashList := ast.And(
		"hashList",
		nil,
		leftBrace, hash, rightBrace,
	)

	// Ast parameter list -> ident | indent "," ident
	parameter := ast.Kleene("parameter", nil, ident, comma)
	parameterList := ast.Maybe("parameterList", nil, parameter)

	// Ast block statement -> "{" statements "}"
	blockStatement := ast.And(
		"block",
		nil,
		leftBrace, ast.Maybe("statements", nil, &statements), rightBrace,
	)

	// Ast closure expression -> "fun" "(" parameterList ")" blockStatement
	closureExpression := ast.And(
		"closure",
		nil,
		keywords["fun"], leftParen, parameterList, rightParen, blockStatement,
	)

	// Ast semicolon -> ";" | ""
	maybeSemicolon := ast.Maybe("semicolon", nil, semicolon)

	// Ast call expression -> ident "(" parameterList ")" maybeSemicolon
	callExpression := ast.And(
		"call",
		nil,
		ident, leftParen, parameterList, rightParen, maybeSemicolon,
	)

	// Ast value -> number | string | closure | array | hash | call
	value = ast.OrdChoice("value", nil, number, strings, closureExpression, arrayList, hashList, callExpression)

	// Ast let statement -> "let" ident "=" value maybeSemicolon
	letStatement := ast.And(
		"let",
		nil,
		keywords["let"], ident, assign, value, maybeSemicolon,
	)

	// Ast statements -> letStatement | callExpression
	statements = ast.Many(
		"statements",
		nil,
		ast.OrdChoice("statement", nil, letStatement, callExpression),
	)

	// Ast parse
	node, _ := ast.Parsewith(statements, scanner)

	fmt.Println(node)
	fmt.Println(node.GetValue())
	fmt.Println(len(node.GetChildren()))

	for _, child := range node.GetChildren() {
		fmt.Println(child)
	}

	// Ast Print
	prettyprint(ast, os.Stdout, "", node)

	//
	fmt.Println()
	fmt.Println("Hello World!")
}

func prettyprint(ast *parsec.AST, w io.Writer, prefix string, node parsec.Queryable) {
	if node.IsTerminal() {
		fmt.Fprintf(w, "%v*%v: %q\n", prefix, node.GetName(), node.GetValue())
		return
	}

	fmt.Fprintf(w, "%v%v @ %v\n", prefix, node.GetName(), node.GetPosition())
	for _, child := range node.GetChildren() {
		prettyprint(ast, w, prefix+"  ", child)
	}
}
