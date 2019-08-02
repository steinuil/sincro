package main

import (
	"fmt"
	"io"
	"sincro/protocol"
)

func handleMessage(w io.Writer, msg interface{}) {
	switch msg.(type) {
	case protocol.Hello:
		hello := msg.(protocol.Hello)
		fmt.Println(hello.Motd)
	case protocol.NewControlledRoom:
	case protocol.ControllerAuth:
	case protocol.Ready:
	case protocol.PlaylistIndex:
	case protocol.PlaylistChange:
	case protocol.UserRoomChangeEvent:
	case protocol.UserLeftEvent:
	case protocol.UserJoinedEvent:
	case protocol.UserFileChangeEvent:
	case []protocol.User:
	case protocol.State:
		state := protocol.SendState()
		fmt.Printf("%s\n", string(state))
		w.Write(state)
	default:
		return
	}
}
