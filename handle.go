package main

import (
	"io"
	"sincro/protocol"
)

func handleMessage(w io.Writer, msg interface{}, state *SincroState) {
	switch msg.(type) {
	case protocol.Hello:
		hello := msg.(protocol.Hello)
		state.User = hello.User
		state.Room = hello.Room

		w.Write(protocol.GetUsers())
		w.Write(protocol.Separator)
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
		serverState := msg.(protocol.State)
		state.Position = serverState.Position
		state.IsPaused = serverState.IsPaused

		position := state.Position + serverState.ServerRtt

		w.Write(protocol.SendState(position, state.IsPaused, false, serverState.ServerIgnore))
		w.Write(protocol.Separator)
	default:
		return
	}
}
