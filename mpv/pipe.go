// +build !windows

package mpv

import "io"

const DefaultPipeName = `\\.\pipe\SincroMpvPipe`

func Dial(path string) (io.Conn, error) {

}
