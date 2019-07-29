package protocol

type Features map[string]interface{}

// "Hello" event

// Hello: response to the Hello request
type Hello struct {
	Name     string
	Version  string
	Motd     string
	Room     string
	Features Features
}

// "Set" events

// NewControlledRoom is
type NewControlledRoom struct {
	Room     string `json:"roomName"`
	Password string `json:"password"`
}

type ControllerAuth struct {
	User    string `json:"user"`
	Room    string `json:"room"`
	Success bool   `json:"success"`
}

type Ready struct {
	User                string `json:"username"`
	IsReady             bool   `json:"isReady"`
	IsManuallyInitiated bool   `json:"manuallyInitiated"`
}

type PlaylistIndex struct {
	User  string `json:"user"`
	Index int    `json:"index"`
}

type userRoom struct {
	User string
	Room string
}

type UserRoomChangeEvent userRoom

type UserLeftEvent userRoom

type UserJoinedEvent struct {
	User     string
	Room     string
	Version  string
	Features Features
}

type File struct {
	Name     string
	Duration float64
	Size     int64
	Path     string
}

type UserFileChangeEvent struct {
	User string
	Room string
	File File
}
