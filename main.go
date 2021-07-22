package main

import (
	"fmt"
	"net"
	"sincro/mpv"
	"sincro/protocol"
	"time"
	"os"
	"io"
)

func main() {
	var err error

	conn, err := net.Dial("tcp", "syncplay.pl:8996")
	if err != nil {
		panic(err)
	}

	state := SincroState{
		User:     "steen",
		Room:     "badboys421",
		IsReady:  false,
		IsPaused: true,
		File:     File{},
	}

	conn.Write(protocol.SendHello(state.User, state.Room))
	conn.Write(protocol.Separator)

	_, err = mpv.Open(mpv.DefaultPipeName)
	if err != nil {
		panic(err)
	}

	lines := make(chan []byte)

	go readLines(conn, lines, '\r', 2)

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
			handleSyncplay(io.MultiWriter(conn, os.Stdout), msg, &state)
		}
	}
}
