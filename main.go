package main

import (
	"fmt"
	"net"
	"sincro/protocol"
)

func main() {
	var err error

	conn, err := net.Dial("tcp4", ":8996")
	if err != nil {
		panic(err)
	}

	defer conn.Close()

	var out = make([]byte, 100)

	var read = 0

	for read < 1 {
		read, err = conn.Read(out)
		if err != nil {
			panic(err)
		}
	}
	fmt.Println("read", read)

	fmt.Println(string(out))

	_, _ = protocol.ParseMessage([]byte("ayy"))

	// var hello HelloResp

	// dec := json.NewDecoder(conn)

	// err = dec.Decode(&hello)
	// if err != nil {
	// 	panic(err)
	// }

	// fmt.Println(hello)
}
