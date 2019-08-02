package main

import (
	"io"
	"sincro/protocol"
)

func handleMessage(w io.Writer, msg interface{}) {
	switch msg.(type) {
	case protocol.Hello:
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
		w.Write(state)
		w.Write([]byte("\r\n"))
	default:
		return
	}
}
