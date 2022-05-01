package main

import (
	"fmt"

	parsec "github.com/prataprc/goparsec"
)

const (
    ASSIGN = "ASSIGN"
    PLUS   = "PLUS"
)

func main() {
    //
    keyword := parsec.OrdTokens(
        []string{"let"},
        []string{"LET"},
    )

    ident := parsec.Ident()
    assign := parsec.Atom("=", ASSIGN)
    plus := parsec.Atom("+", PLUS)

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

    fmt.Println(ident, assign)

    //
    var parser parsec.Parser
    var token parsec.Parser

    token = parsec.OrdChoice(
        func(ns []parsec.ParsecNode) parsec.ParsecNode {
            if ns == nil || len(ns) < 1 {
                return nil
            }

            return ns[0]
        },
        keyword,
        ident,
        assign,
        number,
        plus,
    )

    parser = parsec.Kleene(nil, &token)

    fmt.Println(parser)

    //
    content := []byte("let a = 1 let b = 2.2 a + b")
    scanner := parsec.NewScanner(content)

    fmt.Println(scanner)

    //
    root, _ := parser(scanner)
    nodes, _ := root.([]parsec.ParsecNode)

    fmt.Println(root)

    for _, node := range nodes {
        terminal := node.(*parsec.Terminal)

        fmt.Printf(
            "%10s => %-10s\n",
            terminal.GetName(),
            terminal.GetValue(),
        )
    }

    //
    fmt.Println()
    fmt.Println("Hello World!")
}
