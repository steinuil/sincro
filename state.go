package main

import "sincro/protocol"

type File protocol.File

type User protocol.User

type Playlist struct {
	Files    []string
	Position int
}

type SincroState struct {
	User     string
	Room     string
	IsReady  bool
	IsPaused bool
	Position float64
	File     File
	Playlist Playlist
	Users    map[string]User
}
