package protocol

type ServerFeatures struct {
	Chat                 bool `json:"chat"`
	IsolateRooms         bool `json:"isolateRooms"`
	ManagedRooms         bool `json:"managedRooms"`
	FeatureList          bool `json:"featureList,omitempty"`
	Readiness            bool `json:"readiness"`
	MaxChatMessageLength int  `json:"maxChatMessageLength"`
	MaxUsernameLength    int  `json:"maxUsernameLength"`
	MaxRoomNameLength    int  `json:"maxRoomNameLength"`
	MaxFilenameLength    int  `json:"maxFilenameLength"`
}

type ClientFeatures struct {
	Chat            bool `json:"chat,omitempty"`
	ManagedRooms    bool `json:"managedRooms"`
	FeatureList     bool `json:"featureList,omitempty"`
	Readiness       bool `json:"readiness"`
	SharedPlaylists bool `json:"sharedPlaylists,omitempty"`
}

type File struct {
	Filename string  `json:"name"`
	Duration float64 `json:"duration"`
	Size     float64 `json:"size"`
	Path     string  `json:"path,omitempty"`
}

// "Hello" event

// Hello response to the Hello request
type Hello struct {
	User     string
	Version  string
	Motd     string
	Room     string
	Features ServerFeatures
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

type PlaylistChange struct {
	User  string   `json:"user"`
	Files []string `json:"files"`
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
	Features ClientFeatures
}

type UserFileChangeEvent struct {
	User string
	Room string
	File File
}

type User struct {
	User         string         `json:"user"`
	Filename     string         `json:"file"`
	IsReady      bool           `json:"isReady"`
	IsController bool           `json:"controller"`
	Features     ClientFeatures `json:"features"`
}

type State struct {
	Position           float64
	DoSeek             bool
	IsPaused           bool
	SetByUser          string
	LatencyCalculation float64
	ServerIgnore       int
	ServerRtt          float64
}
