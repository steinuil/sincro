package main

import (
	"io"
	"sincro/protocol"
)

func handleSyncplay(w io.Writer, msg interface{}, state *SincroState) {
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
		ready := msg.(protocol.Ready)

		user := state.Users[ready.User]
		user.IsReady = ready.IsReady

		state.Users[ready.User] = user
	case protocol.PlaylistIndex:
		playlistIndex := msg.(protocol.PlaylistIndex)
		state.Playlist.Position = playlistIndex.Index
	case protocol.PlaylistChange:
		playlistChange := msg.(protocol.PlaylistChange)
		state.Playlist = Playlist{
			Position: 0,
			Files:    playlistChange.Files,
		}
	case protocol.UserRoomChangeEvent:
		// the fuck does event this mean
		// userRoomChangeEvent := msg.(protocol.UserRoomChangeEvent)
	case protocol.UserLeftEvent:
		userLeftEvent := msg.(protocol.UserLeftEvent)
		delete(state.Users, userLeftEvent.User)
	case protocol.UserJoinedEvent:
		userJoinedEvent := msg.(protocol.UserJoinedEvent)
		state.Users[userJoinedEvent.User] = User{
			User:     userJoinedEvent.User,
			Features: userJoinedEvent.Features,
		}
	case protocol.UserFileChangeEvent:
		userFileChangeEvent := msg.(protocol.UserFileChangeEvent)

		user := state.Users[userFileChangeEvent.User]
		user.Filename = userFileChangeEvent.File.Filename

		state.Users[userFileChangeEvent.User] = user
	case []protocol.User:
		users := msg.([]User)
		state.Users = make(map[string]User)
		for _, user := range users {
			state.Users[user.User] = user
		}
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
