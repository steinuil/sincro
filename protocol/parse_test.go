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
