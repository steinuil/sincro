package protocol

import (
	"testing"

	"gotest.tools/assert"
)

func TestParseHello(t *testing.T) {
	data := []byte(`{
		"username":"test",
		"room":{"name":"testroom"},
		"realversion": "1.6.4",
		"version":"1.2.255",
		"motd":"testmotd",
		"features":{
			"chat":false,
			"isolateRooms":true,
			"managedRooms":true,
			"readiness":true,
			"maxChatMessageLength":240,
			"maxUsernameLength":36,
			"maxRoomNameLength":32,
			"maxFilenameLength":256
		}
	}`)

	hello, err := parseHello(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, hello, Hello{
		User:    "test",
		Room:    "testroom",
		Version: "1.6.4",
		Motd:    "testmotd",
		Features: ServerFeatures{
			Chat:                 false,
			IsolateRooms:         true,
			ManagedRooms:         true,
			Readiness:            true,
			MaxChatMessageLength: 240,
			MaxUsernameLength:    36,
			MaxRoomNameLength:    32,
			MaxFilenameLength:    256,
		},
	})
}

func TestParseNewControlledRoom(t *testing.T) {
	data := []byte(`{
		"roomName":"theroom",
		"password":"swordfish"
  }`)

	n, err := parseNewControlledRoom(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, NewControlledRoom{
		Room:     "theroom",
		Password: "swordfish",
	})
}

func TestParseControllerAuth(t *testing.T) {
	data := []byte(`{
		"user":"me",
		"room":"this",
		"success":false
	}`)

	n, err := parseControllerAuth(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, ControllerAuth{
		User:    "me",
		Room:    "this",
		Success: false,
	})
}

func TestParseReady(t *testing.T) {
	data := []byte(`{
		"username":"maroka",
		"isReady":true,
		"manuallyInitiated":true
	}`)

	n, err := parseReady(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, Ready{
		User:                "maroka",
		IsReady:             true,
		IsManuallyInitiated: true,
	})
}

func TestParsePlaylistIndex(t *testing.T) {
	data := []byte(`{
		"user":"maroka",
		"index":42
	}`)

	n, err := parsePlaylistIndex(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, PlaylistIndex{
		User:  "maroka",
		Index: 42,
	})
}

func TestParseUser1(t *testing.T) {
	data := []byte(`{
		"maroka":{
			"event":{"left":true},
			"room":{"name":"testroom"}
		}
	}`)

	n, err := parseUser(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, UserLeftEvent{
		User: "maroka",
		Room: "testroom",
	})
}

func TestParseUser2(t *testing.T) {
	data := []byte(`{
		"maroka":{
			"event":{
				"joined": true,
				"version": "1.6.4",
				"features":{
					"sharedPlaylists": true,
					"managedRooms": true,
					"readiness": true,
					"featureList": true,
					"chat": true
				}
			},
			"room": {"name": "testroom"}
		}
	}`)

	n, err := parseUser(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, UserJoinedEvent{
		User:    "maroka",
		Room:    "testroom",
		Version: "1.6.4",
		Features: ClientFeatures{
			SharedPlaylists: true,
			ManagedRooms:    true,
			Readiness:       true,
			FeatureList:     true,
			Chat:            true,
		},
	})
}

func TestParseState(t *testing.T) {
	data := []byte(`{
		"ping":{
			"serverRtt": 3.2,
			"latencyCalculation": 1564749326.7353718,
			"clientLatencyCalculation": 1564749327.5809891
		},
		"playstate":{
			"position": 0,
			"doSeek": false,
			"paused": true,
			"setBy": "maroka"
		},
		"ignoringOnTheFly":{"server": 1}
	}`)

	n, err := parseState(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, n, State{
		LatencyCalculation: 1564749326.7353718,
		Position:           0,
		DoSeek:             false,
		IsPaused:           true,
		SetByUser:          "maroka",
		ServerIgnore:       1,
		ServerRtt:          3.2,
	})
}
