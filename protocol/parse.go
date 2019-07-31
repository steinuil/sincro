package protocol

import "encoding/json"

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
	out.Motd = resp.Motd
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

// TODO handle errors

func parseFileChanged(file map[string]interface{}, user string, room string) (UserFileChangeEvent, error) {
	out := UserFileChangeEvent{
		User: user,
		Room: room,
		File: File{
			Filename: file["name"].(string),
			Duration: file["duration"].(float64),
			Size:     file["size"].(int64),
			Path:     file["path"].(string),
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
		features := ev["features"].(map[string]bool)

		out := UserJoinedEvent{
			User:    user,
			Room:    room,
			Version: ev["version"].(string),
			Features: ClientFeatures{
				Chat:            features["chat"],
				ManagedRooms:    features["managedRooms"],
				FeatureList:     features["featureList"],
				Readiness:       features["readiness"],
				SharedPlaylists: features["sharedPlaylists"],
			},
		}

		return out, nil
	}

	return nil, nil // TODO return error
}

func parseUser(data []byte) (interface{}, error) {
	var dec map[string]map[string]interface{}

	var user string

	for k := range dec {
		user = k
		break
	}

	info := dec[user]

	room := info["room"].(map[string]string)["name"]

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

	switch {
	case ev["newControlledRoom"] != nil:
		return parseNewControlledRoom(ev["newControlledRoom"])
	case ev["controllerAuth"] != nil:
		return parseControllerAuth(ev["controllerAuth"])
	case ev["ready"] != nil:
		return parseReady(ev["ready"])
	case ev["playlistChange"] != nil:
		return parsePlaylistIndex(ev["playlistChange"])
	case ev["playlistIndex"] != nil:
		return parsePlaylistIndex(ev["playlistIndex"])
	case ev["user"] != nil:
		return parseUser(ev["user"])
	case ev["features"] != nil:
		return nil, nil
	default:
		return nil, nil
	}
}
