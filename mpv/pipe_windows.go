package mpv

import (
	"net"
	"time"

	"github.com/Microsoft/go-winio"
)

const DefaultPipeName = `\\.\pipe\SincroMpvPipe`

func Dial(path string) (net.Conn, error) {
	timeout := time.Second * 10

	return winio.DialPipe(path, &timeout)
}
