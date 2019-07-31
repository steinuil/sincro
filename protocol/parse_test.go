package protocol

import "testing"

func TestParseHello(t *testing.T) {
	var data = []byte(`{
    "username":"test",
    "room":{"name":"testroom"},
    "realversion": "1.6.4",
    "version":"1.2.255",
    "motd":"testmotd",
    "features":{
      "chat":false,
      "featureList":true,
      "managedRooms":true,
      "readiness":true,
      "sharedPlaylists":false
    }
  }`)

	hello, err := parseHello(data)
	if err != nil {
		t.Error(err)
	}

	if hello.User != "test" {
		t.Errorf("hello.User: expected %s, got %s", "test", hello.User)
	}

	if hello.Room != "testroom" {
		t.Errorf("hello.Room: expected %s, got %s", "testroom", hello.Room)
	}

	if hello.Version != "1.6.4" {
		t.Errorf("hello.Version: expected %s, got %s", "1.6.4", hello.Version)
	}

	if hello.Motd != "testmotd" {
		t.Errorf("hello.Motd: expected %s, got %s", "testmotd", hello.Motd)
	}

	if hello.Features.Chat != false {
		t.Errorf("hello.Features.Chat: expected %t, got %t", false, hello.Features.Chat)
	}
}
