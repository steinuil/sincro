pkgs = . ./protocol ./mpv

.PHONY: fmt
fmt:
	go fmt $(pkgs)
