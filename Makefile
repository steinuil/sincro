pkgs = . ./protocol

.PHONY: fmt
fmt:
	go fmt $(pkgs)
