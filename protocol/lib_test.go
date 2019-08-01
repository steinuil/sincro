package protocol

import (
	"testing"

	"gotest.tools/assert"
)

func TestParseMessage1(t *testing.T) {
	data := []byte(`{"Set": {"playlistChange": {"files": [],"manuallyInitiated": false, "isReady": null}}}`)

	set, err := ParseMessage(data)
	if err != nil {
		t.Error(err)
	}

	assert.DeepEqual(t, set.(PlaylistChange), PlaylistChange{
		Files: []string{},
	})
}
