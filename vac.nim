# Protocol for JSON  websocket  communication

import tables
import ws,asyncdispatch,asynchttpserver,sharedlist

var clients : SharedList[Websocket]
#var clients : seq[WebSocket]

type cmd_t = object
    cmd: string
    arg0: string

proc vac_setup*() =
  echo "vac_setup"

proc iterate(ws: Websocket): bool =
  if ws.readyState == Open:
#    await ws.sendPacket(
    echo "send...."
  return false

proc vac_broadcast*(msg: string) {.async.} =
  echo "broadcast"
  var i=0
  for ws in clients:
    if ws.readyState == Open:
      echo "sending to " & $i
      discard ws.sendPacket(msg)
    inc(i)
#  clients.iterAndMutate(iterate)
#[
  clients.iterAndMutate((proc (cli: Websocket): Future[bool] {.async.} =
    if cli.readyState == Open:
      echo "sending" & msg
    return false
  ))
]#

proc serveVAC*(req: Request, path: seq[string], options: TableRef[string, string]) {.async.} =

  var ws = await newWebsocket(req)
  if path[2] == "attach":
    clients.add(ws)
  else:
    echo "stub"
