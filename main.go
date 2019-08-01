package main

import (
	"bytes"
	"fmt"
	"io"
	"net"
	"sincro/protocol"
	"time"
)

func readLines(r io.Reader, out chan<- string) {
	var buf = make([]byte, 128)

	var line = bytes.Buffer{}

	for {
		read, err := r.Read(buf)
		if read == 0 && err == io.EOF {
			close(out)
			return
		}
		if err != nil && err != io.EOF {
			panic(err)
		}

		nl := bytes.Index(buf, []byte("\r\n"))
		if nl != -1 {
			line.Write(buf[:nl])
			out <- line.String()
			line.Reset()
			buf = buf[nl+2:]
		}

		line.Write(buf)
	}
}

func main() {
	var err error

	conn, err := net.Dial("tcp", "syncplay.pl:8996")
	if err != nil {
		panic(err)
	}

	conn.Write(protocol.SendHello("steen", "badboys421"))
	conn.Write([]byte("\r\n"))

	var lines = make(chan string, 4)

	go readLines(conn, lines)

	for line := range lines {
		time.Sleep(0)
		fmt.Println("line", string(line))
		msg, err := protocol.ParseMessage([]byte(line))
		if err != nil {
			fmt.Errorf("%s", err)
		}
		fmt.Printf("%v\n", msg)
	}
}
