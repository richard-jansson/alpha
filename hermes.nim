# External 
import ws,asyncdispatch,asynchttpserver,json,strutils,tables,threadpool
# Internal 
import vac,stat,coltrane


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
    elif paths.len >= 2 :
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

    echo "category: " & category

    if category == "ws":
      echo "websocket is stub"
      await serveVAC(req,paths,params)
    else :
      await serveStatic(req,"." & req.url.path)

var server = newAsyncHttpServer()

vac_setup()
var ch = coltrane_init()

spawn coltrane_do()

asyncCheck server.serve(Port(port),reqcback)

while true:
  echo "trying to read"
  var rc = ch[].tryRecv()
  if rc.dataAvailable==true:
    echo "got data from coltrane: " & rc.msg
    var f=vac_broadcast(rc.msg)
  else:
    echo "nothing from coltrane"

  echo "polling..."
  asyncdispatch.poll()
