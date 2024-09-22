package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"time"
)

const (
	max_row   = 1_000
	chunk_row = 100
)

func create_insert_statements(start, end int, ch chan<- string) {
	var buf bytes.Buffer

	for i := start; i < end; i++ {
		statement := fmt.Sprintf(
			"insert into table (id, a, b, t) values (%d, %d, %d, %d);\n",
			i, 1, 2, time.Now().UnixMicro(),
		)

		buf.WriteString(statement)
	}

	ch <- buf.String()
}

func main() {
	fmt.Println("Gen ...")

	ch := make(chan string)

	for i := 0; i < max_row; i += chunk_row {
		fmt.Printf("Sending %d..%d\n", i, i+chunk_row)

		go create_insert_statements(i, i+chunk_row, ch)
	}

	f, _ := os.Create("./insert.txt")
	w := bufio.NewWriter(f)

	for i := 0; i < max_row; i += chunk_row {
		select {
		case statements := <-ch:
			w.WriteString(statements)
		}
	}

	w.Flush()
	f.Close()
	close(ch)
}
