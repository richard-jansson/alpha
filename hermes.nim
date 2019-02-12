import ws,asyncdispatch,asynchttpserver,json,strutils,tables,stat

let port = 10000

type cmd_t = object
    cmd: string
    arg0: string

proc prof(cmd0: string, arg0: string) =
  echo "Prof stub " & cmd0 & " " & arg0

proc pred(cmd0: string, arg0: string) =
  echo "Prof " & cmd0 & " " & arg0

proc listen(cmd0: string, arg0: string) =
  echo "Prof " & cmd0 & " " & arg0

proc reqcback(req: Request) {.async,gcsafe.} =
    var paths = req.url.path.split({'/'})
    var query = req.url.query.split({'&'})

    var params = newTable[string,string]()
    var category = "default"
    var action = "default"

    if paths.len == 1 :
      category = paths[0]
    elif paths.len == 2 :
      category = paths[0]
      category = paths[1]

    for k,v in query:
        var i = v.find("=")
        if i < 1 :
          params[v]="true"
        else :
          var a=v[0..i-1]
          var b=v[i+1..v.len-1]
          params[a]=b

    if category == "ws":
      echo "websocket is stub"
    else :
      await serveStatic(req,"." & req.url.path)

proc reqcback2(req: Request) {.async,gcsafe.} =
    var ws = await newWebsocket(req)
#    echo req.url.path
#    echo req.url.query

    var paths = req.url.path.split({'/'})
    var query = req.url.query.split({'&'})

    var params = newTable[string,string]()
  
    var category = "default"
    var action = "default"

    if paths.len == 1 :
      category = paths[0]
    elif paths.len == 2 :
      category = paths[0]
      category = paths[1]

    for k,v in query:
        var i = v.find("=")
        if i < 1 :
          params[v]="true"
        else :
          var a=v[0..i-1]
          var b=v[i+1..v.len-1]
          params[a]=b

    while ws.readyState == Open:
        try:
            let packet = await ws.receiveStrPacket()
            var cmd0: string 
            var arg0: string
            try:
                let jo = parseJSON(packet)
                let cmd = to(jo,cmd_t)
                cmd0=cmd.cmd
                arg0=cmd.arg0
                echo arg0
            except:
                echo "Failed to parse message"
            try:
              await ws.sendPacket("whatever")
            except:
                echo "failed to send"
        except:
            echo "failed to wait"

var server = newAsyncHttpServer()

waitFor server.serve(Port(port),reqcback)
