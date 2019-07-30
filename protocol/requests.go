package protocol

import "encoding/json"
import "encoding/hex"
import "crypto/md5"

type ClientFeatures struct {
	SharedPlaylists bool `json:"sharedPlaylists,omitempty"`
	Chat            bool `json:"chat,omitempty"`
	FeatureList     bool `json:"featureList,omitempty"`
	Readiness       bool `json:"readiness"`
	ManagedRooms    bool `json:"managedRooms"`
}

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

func SendHello(user string, room string) ([]byte, error) {
	return json.Marshal(makeHello(user, room))
}

func SendHelloAuth(user string, room string, password string) ([]byte, error) {
	sum := md5.Sum([]byte(password))

	h := makeHello(user, room)
	h.Password = hex.EncodeToString(sum[:])

	return json.Marshal(struct{ Hello hello }{Hello: h})
}

func SendFile(file File) ([]byte, error) {
	type f struct {
		File File `json:"file"`
	}

	return json.Marshal(struct{ Set f }{Set: f{
		File: file,
	}})
}

func SwitchToRoom(room string) ([]byte, error) {
	type r struct {
		Room roomName `json:"room"`
	}

	return json.Marshal(struct{ Set r }{Set: r{
		Room: roomName{Name: room},
	}})
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

func RequestControlledRoom(room string) ([]byte, error) {
	return json.Marshal(struct{ Set controllerAuth }{Set: controllerAuth{
		ControllerAuth: roomPassword{
			Room:     room,
			Password: genRoomPassword(),
		},
	}})
}

func ManageRoom(room string, password string) ([]byte, error) {
	return json.Marshal(struct{ Set controllerAuth }{Set: controllerAuth{
		ControllerAuth: roomPassword{
			Room:     room,
			Password: password,
		},
	}})
}

type readyStatus struct {
	IsReady           bool `json:"isReady"`
	ManuallyInitiated bool `json:"manuallyInitiated"`
}

type ready struct {
	Ready readyStatus `json:"ready"`
}

func SetReady(isReady bool) ([]byte, error) {
	return json.Marshal(struct{ Set ready }{Set: ready{
		Ready: readyStatus{
			IsReady:           isReady,
			ManuallyInitiated: false,
		},
	}})
}

func SetReadyManually(isReady bool) ([]byte, error) {
	return json.Marshal(struct{ Set ready }{Set: ready{
		Ready: readyStatus{
			IsReady:           isReady,
			ManuallyInitiated: true,
		},
	}})
}

func SetPlaylist(files []string) ([]byte, error) {
	type filesT struct {
		Files []string `json:"files"`
	}

	type playlistChange struct {
		PlaylistChange filesT `json:"playlistChange"`
	}

	return json.Marshal(struct{ Set playlistChange }{Set: playlistChange{
		PlaylistChange: filesT{
			Files: files,
		},
	}})
}

func SkipToPlaylistIndex(index int) ([]byte, error) {
	type indexT struct {
		Index int `json:"index"`
	}

	type playlistIndex struct {
		PlaylistIndex indexT `json:"playlistIndex"`
	}

	return json.Marshal(struct{ Set playlistIndex }{Set: playlistIndex{
		PlaylistIndex: indexT{
			Index: index,
		},
	}})
}

func SetFeatures(features ClientFeatures) ([]byte, error) {
	type featuresT struct {
		Features ClientFeatures `json:"features"`
	}

	return json.Marshal(struct{ Set featuresT }{Set: featuresT{
		Features: features,
	}})
}

func GetUsers() ([]byte, error) {
	type list struct {
		List interface{}
	}

	return json.Marshal(list{
		List: nil,
	})
}
