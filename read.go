package main

import (
	"bytes"
	"io"
)

func readLines(r io.Reader, out chan<- []byte, sep byte, sepLen int) {
	buf := make([]byte, 128)
	line := bytes.Buffer{}

	for {
		read, err := r.Read(buf)

		if read < 1 && err == io.EOF {
			close(out)
			return
		}

		if err != nil && err != io.EOF {
			panic(err)
		}

		bufSlice := buf[:read]

		for {
			nl := bytes.IndexByte(bufSlice, sep)

			if nl != -1 {
				line.Write(bufSlice[:nl])

				lineCopy := make([]byte, line.Len())
				copy(lineCopy, line.Bytes())

				out <- lineCopy
				line.Reset()

				bufSlice = bufSlice[nl+sepLen:]
			} else {
				line.Write(bufSlice)
				break
			}
		}
	}
}
