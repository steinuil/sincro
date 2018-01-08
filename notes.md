Notes from digging through the [syncplay](https://github.com/syncplay/syncplay)
codebase.

## `client.py`
### `SyncClientFactory`
* returns a SyncClientProtocol
* defines some callbacks that get called when the client is connected or disconnected
* handles retrying to connect when the connection is lost or failed

### `SyncplayClient`
* handles everything and the kitchen sink
* FINISH READING

### `SyncplayUser`
