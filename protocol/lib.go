package protocol

import "encoding/json"

func ParseMessage(data []byte) (interface{}, error) {
	var out map[string]json.RawMessage

	err := json.Unmarshal(data, &out)
	if err != nil {
		return nil, err
	}

	switch {
	case out["Hello"] != nil:
		return parseHello(out["Hello"])
	case out["Set"] != nil:
		return parseSet(out["Set"])
	case out["List"] != nil:
		return parseList(out["List"])
	default:
		return nil, nil // ERROR HERE
	}
}
