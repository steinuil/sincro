package protocol

import "testing"

func TestParseHello(t *testing.T) {
	var data = []byte(`{"username":"steen","room":{"name":"badboys420"},"realversion":"1.6.4","version":"1.2.255","features":{"chat":false,"featureList":true,"managedRooms":true,"readiness":true,"sharedPlaylists":false}}`)

	_, err := parseHello(data)
	if err != nil {
		t.Error(err)
	}
}
