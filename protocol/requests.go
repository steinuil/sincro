package protocol

import "encoding/json"
import "encoding/hex"
import "crypto/md5"

type roomName struct {
	Name string `json:"name"`
}

type hello struct {
	User        string         `json:"username"`
	Room        roomName       `json:"room"`
	Version     string         `json:"version"`
	Realversion string         `json:"realversion"`
	Password    string         `json:"password,omitempty"`
	Features    ClientFeatures `json:"features"`
}

func makeHello(user string, room string) hello {
	return hello{
		User: user,
		Room: roomName{
			Name: room,
		},
		Version:     "1.2.255",
		Realversion: "1.6.4",
		Features: ClientFeatures{
			SharedPlaylists: false,
			Chat:            false,
			FeatureList:     true,
			Readiness:       true,
			ManagedRooms:    true,
		},
	}
}

func SendHello(user string, room string) []byte {
	out, err := json.Marshal(struct{ Hello hello }{Hello: makeHello(user, room)})
	if err != nil {
		panic(err)
	}
	return out
}

func SendHelloAuth(user string, room string, password string) []byte {
	sum := md5.Sum([]byte(password))

	h := makeHello(user, room)
	h.Password = hex.EncodeToString(sum[:])

	out, err := json.Marshal(struct{ Hello hello }{Hello: h})
	if err != nil {
		panic(err)
	}
	return out
}

func SendFile(file File) []byte {
	type f struct {
		File File `json:"file"`
	}

	out, err := json.Marshal(struct{ Set f }{Set: f{
		File: file,
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func SwitchToRoom(room string) []byte {
	type r struct {
		Room roomName `json:"room"`
	}

	out, err := json.Marshal(struct{ Set r }{Set: r{
		Room: roomName{Name: room},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

type roomPassword struct {
	Room     string `json:"room"`
	Password string `json:"password"`
}

type controllerAuth struct {
	ControllerAuth roomPassword
}

func genRoomPassword() string {
	return ""
}

func RequestControlledRoom(room string) []byte {
	out, err := json.Marshal(struct{ Set controllerAuth }{Set: controllerAuth{
		ControllerAuth: roomPassword{
			Room:     room,
			Password: genRoomPassword(),
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func ManageRoom(room string, password string) []byte {
	out, err := json.Marshal(struct{ Set controllerAuth }{Set: controllerAuth{
		ControllerAuth: roomPassword{
			Room:     room,
			Password: password,
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

type readyStatus struct {
	IsReady           bool `json:"isReady"`
	ManuallyInitiated bool `json:"manuallyInitiated"`
}

type ready struct {
	Ready readyStatus `json:"ready"`
}

func SetReady(isReady bool) []byte {
	out, err := json.Marshal(struct{ Set ready }{Set: ready{
		Ready: readyStatus{
			IsReady:           isReady,
			ManuallyInitiated: false,
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func SetReadyManually(isReady bool) []byte {
	out, err := json.Marshal(struct{ Set ready }{Set: ready{
		Ready: readyStatus{
			IsReady:           isReady,
			ManuallyInitiated: true,
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func SetPlaylist(files []string) []byte {
	type filesT struct {
		Files []string `json:"files"`
	}

	type playlistChange struct {
		PlaylistChange filesT `json:"playlistChange"`
	}

	out, err := json.Marshal(struct{ Set playlistChange }{Set: playlistChange{
		PlaylistChange: filesT{
			Files: files,
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func SkipToPlaylistIndex(index int) []byte {
	type indexT struct {
		Index int `json:"index"`
	}

	type playlistIndex struct {
		PlaylistIndex indexT `json:"playlistIndex"`
	}

	out, err := json.Marshal(struct{ Set playlistIndex }{Set: playlistIndex{
		PlaylistIndex: indexT{
			Index: index,
		},
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func SetFeatures(features ClientFeatures) []byte {
	type featuresT struct {
		Features ClientFeatures `json:"features"`
	}

	out, err := json.Marshal(struct{ Set featuresT }{Set: featuresT{
		Features: features,
	}})
	if err != nil {
		panic(err)
	}
	return out
}

func GetUsers() []byte {
	type list struct {
		List interface{}
	}

	out, err := json.Marshal(list{
		List: nil,
	})
	if err != nil {
		panic(err)
	}
	return out
}

func SendState() []byte {
	type state struct {
		State stateReq
	}

	out, err := json.Marshal(state{State: stateReq{
		Playstate: playstateReq{},
		Ping:      pingReq{},
	}})
	if err != nil {
		panic(err)
	}
	return out
}
