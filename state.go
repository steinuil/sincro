package main

import "sincro/protocol"

type File protocol.File

type User protocol.User

type SincroState struct {
	User     string
	Room     string
	IsReady  bool
	IsPaused bool
	Position float64
	File     File
	Users    []User
}
