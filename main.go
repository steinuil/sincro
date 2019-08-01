package main

import (
	"fmt"
	"net"
	"sincro/protocol"
	"time"
)

func main() {
	var err error

	conn, err := net.Dial("tcp", "syncplay.pl:8996")
	if err != nil {
		panic(err)
	}

	conn.Write(protocol.SendHello("steen", "badboys421"))
	conn.Write([]byte("\r\n"))

	lines := make(chan []byte)

	go readLines(conn, lines)

	for line := range lines {
		time.Sleep(0)

		msg, err := protocol.ParseMessage(line)
		if err != nil {
			fmt.Errorf("%s", err)
		}

		if msg == nil {
			fmt.Printf("%v\n", string(line))
		} else {
			fmt.Printf("%#v\n", msg)
		}
	}
}
