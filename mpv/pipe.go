// +build !windows

package mpv

import (
	"io"
	"os"
)

const DefaultPipeName = `/tmp/sincro-mpv-pipe`

func Open(path string) (io.ReadWriteCloser, error) {
	return os.OpenFile(path, os.O_RDWR, os.ModeNamedPipe)
}
