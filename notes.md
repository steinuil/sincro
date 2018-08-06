Notes from digging through the [syncplay](https://github.com/syncplay/syncplay)
codebase.


# Responses
The protocol as of version 1.5.1.

    Hello: {
      username: <username>
      room: { name: <room name> }
      version: <version string>
      realversion: <version string>
      motd: <string>
      features: {
      }
    }

    List: [
      { <room name>: {
          username: <username>
          position: <file position>
          file: null | {
            name: <filename>
            duration: <file duration>
            size: <file size>
            path: <file path>
          }
          isController: <boolean>
          isReady: null | <boolean>
        }
      }
    ]

    Error: {
      message: <string>
    }

    Chat: {
      message: <string>
      username: <username>
    }


# Security
The protocol is not encrypted, the server password is only hashed to md5
when sent over the wire, and for some reason the room password is only
accepted when it's in a very specific format, which basically makes it
about as secure as a 4 characters password.

All the places where they could've used something like secrets, they just
used random.

The holy grail of syncplay security though is found in the controlled room
name generator, which sha256 hashes the salt (which is **global** to the server),
then sha256 hashes the room name + hashed salt, and finally takes the first
12 characters of the sha1 hash of the previous hash + hashed salt + the
room password.

The developers have clearly given up on securing the protocol by now, because
they don't know how to implement it without breaking backwards compatibility.
Apparently they hope to fix this by 2.0, which is most likely not coming any
time soon.


# IgnoringOnTheFly
IgnoringOnTheFly seems to be some kind of keepalive mechanism,
where the server won't send any state messages until the client has ACKed
the previous by sending back to the server the current server IOTF status.
The same happens for the client: if the client sends its state to the server,
it will increase its local IOTF status and not send new states until the
server has acknowledged it.

The naming is very unfortunate, it took me a while to figure out what the hell
this was for. Also, it doesn't make much sense to put this into the same
command to send the player state.
