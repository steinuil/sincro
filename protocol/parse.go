package protocol

import (
	"encoding/json"
	"strings"
)

func parseHello(data []byte) (Hello, error) {
	var out Hello

	var resp struct {
		User    string `json:"username"`
		Version string `json:"realversion"`
		Motd    string `json:"motd"`
		Room    struct {
			Name string `json:"name"`
		} `json:"room"`
		Features ServerFeatures `json:"features"`
	}

	err := json.Unmarshal(data, &resp)
	if err != nil {
		return out, err
	}

	out.User = resp.User
	out.Version = resp.Version
	out.Motd = strings.TrimSpace(resp.Motd)
	out.Room = resp.Room.Name
	out.Features = resp.Features

	return out, nil
}

func parseNewControlledRoom(data []byte) (NewControlledRoom, error) {
	var out NewControlledRoom

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

func parseControllerAuth(data []byte) (ControllerAuth, error) {
	var out ControllerAuth

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

func parseReady(data []byte) (Ready, error) {
	var out Ready

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

func parsePlaylistIndex(data []byte) (PlaylistIndex, error) {
	var out PlaylistIndex

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

func parsePlaylistChange(data []byte) (PlaylistChange, error) {
	var out PlaylistChange

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

// TODO handle errors

func parseFileChanged(file map[string]interface{}, user string, room string) (UserFileChangeEvent, error) {
	var path string
	if file["path"] != nil {
		path = file["path"].(string)
	}

	out := UserFileChangeEvent{
		User: user,
		Room: room,
		File: File{
			Filename: file["name"].(string),
			Duration: file["duration"].(float64),
			Size:     file["size"].(float64),
			Path:     path,
		},
	}

	return out, nil
}

func parseEvent(ev map[string]interface{}, user string, room string) (interface{}, error) {
	if ev["left"] != nil {
		out := UserLeftEvent{
			User: user,
			Room: room,
		}

		return out, nil
	}

	if ev["joined"] != nil {
		features := ev["features"].(map[string]interface{})

		out := UserJoinedEvent{
			User:    user,
			Room:    room,
			Version: ev["version"].(string),
			Features: ClientFeatures{
				Chat:            features["chat"].(bool),
				ManagedRooms:    features["managedRooms"].(bool),
				FeatureList:     features["featureList"].(bool),
				Readiness:       features["readiness"].(bool),
				SharedPlaylists: features["sharedPlaylists"].(bool),
			},
		}

		return out, nil
	}

	return nil, nil // TODO return error
}

func parseFeatures(data []byte) (ServerFeatures, error) {
	var out ServerFeatures

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

func parseUser(data []byte) (interface{}, error) {
	var dec map[string]map[string]interface{}
	json.Unmarshal(data, &dec)

	var user string

	for k := range dec {
		user = k
		break
	}

	info := dec[user]

	room := info["room"].(map[string]interface{})["name"].(string)

	switch {
	case info["file"] != nil:
		return parseFileChanged(info["file"].(map[string]interface{}), user, room)
	case info["event"] != nil:
		return parseEvent(info["event"].(map[string]interface{}), user, room)
	default:
		return UserRoomChangeEvent{Room: room, User: user}, nil
	}
}

func parseSet(data []byte) (interface{}, error) {
	var ev map[string]json.RawMessage

	json.Unmarshal(data, &ev)

	switch {
	case ev["newControlledRoom"] != nil:
		return parseNewControlledRoom(ev["newControlledRoom"])
	case ev["controllerAuth"] != nil:
		return parseControllerAuth(ev["controllerAuth"])
	case ev["ready"] != nil:
		return parseReady(ev["ready"])
	case ev["playlistChange"] != nil:
		return parsePlaylistChange(ev["playlistChange"])
	case ev["playlistIndex"] != nil:
		return parsePlaylistIndex(ev["playlistIndex"])
	case ev["user"] != nil:
		return parseUser(ev["user"])
	case ev["features"] != nil:
		return parseFeatures(ev["features"])
	default:
		return nil, nil // error!
	}
}

func parseList(data []byte) ([]User, error) {
	var out []User

	err := json.Unmarshal(data, &out)
	if err != nil {
		return out, err
	}

	return out, nil
}

type serverIgnore struct {
	Server int `json:"server"`
}

type pingReq struct {
	LatencyCalculation       float64 `json:"latencyCalculation,omitempty"`
	ClientLatencyCalculation float64 `json:"clientLatencyCalculation"`
	ServerRtt                float64 `json:"serverRtt,omitempty"`
}

type playstateReq struct {
	Position  float64 `json:"position"`
	DoSeek    bool    `json:"doSeek"`
	IsPaused  bool    `json:"paused"`
	SetByUser *string `json:"setBy,omitempty"`
}

type stateReq struct {
	Ping      pingReq      `json:"ping"`
	Playstate playstateReq `json:"playstate"`
	Ignore    serverIgnore `json:"ignoringOnTheFly"`
}

func parseState(data []byte) (State, error) {
	var out State
	var resp stateReq

	err := json.Unmarshal(data, &resp)
	if err != nil {
		return out, err
	}

	out.Position = resp.Playstate.Position
	out.DoSeek = resp.Playstate.DoSeek
	out.IsPaused = resp.Playstate.IsPaused
	if resp.Playstate.SetByUser != nil {
		out.SetByUser = *resp.Playstate.SetByUser
	}
	out.LatencyCalculation = resp.Ping.LatencyCalculation
	out.ServerIgnore = resp.Ignore.Server
	out.ServerRtt = resp.Ping.ServerRtt

	return out, nil
}
