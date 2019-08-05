package mpv

import (
	"time"
	"io"

	"github.com/Microsoft/go-winio"
)

const DefaultPipeName = `\\.\pipe\SincroMpvPipe`

func Open(path string) (io.ReadWriteCloser, error) {
	timeout := time.Second * 10

	return winio.DialPipe(path, &timeout)
}
