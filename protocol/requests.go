package protocol

import "encoding/json"
import "encoding/hex"
import "crypto/md5"

type clientFeatures struct {
	SharedPlaylists bool `json:"sharedPlaylists"`
	Chat            bool `json:"chat"`
	FeatureList     bool `json:"featureList"`
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
	Features    clientFeatures `json:"features"`
}

func makeHello(user string, room string) hello {
	return hello{
		User: user,
		Room: roomName{
			Name: room,
		},
		Version:     "1.2.255",
		Realversion: "1.6.4",
		Features: clientFeatures{
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

	hello := makeHello(user, room)
	hello.Password = hex.EncodeToString(sum[:])

	return json.Marshal(hello)
}

// func SendFile(name string, duration float64, size int64, path string) () {
// 	return json.Marshal()
// }
