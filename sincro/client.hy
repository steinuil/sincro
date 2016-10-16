; SyncplayClientFactory:
; Inherits from twisted.internet.protocol.ClientFactory.
; Connects to the server. Retries a few times.

; SyncplayClient:
; - checks for updates (why here?)
; - manages room password
; - sets ready status

; SyncplayUser:
; User class. Mainly manages user settings.
; Unneeded.

; SyncplayUserlist:
; Functions to deal with the user list. Might reimplement part of this.

; UiManager:
; Glue between the client and the UI?
; No UI part here so we don't care about this.

; SyncplayPlaylist:
; Manages the playlist.
; >_getFilenameFromIndexInGivenPlaylist
; lol. I think that's more then enough to know whether we need to keep this.

; FileSwitchManager:
; Manages "media directories"
; Searches known media directories for the filename the other users are using?
; Not sure what the update stuff means. Probably to deal with threading.
;
; The funniest part is when it has to spin up the hard drives to prevent timeout,
; and throws an error only AFTER it's done searching if it took too long.
;
; And I mean, notifyUserIfFileNotInMediaDirectory?
; Why all this ad-hoc error handling?
;
; We don't need this crap.
