# Serve static files

import asyncdispatch,asynchttpserver

proc serveStatic*(req: Request,path: string) {.async.} =
  var mime = "text/html"


  var content : string
  try:
    content = readFile(path)
  except:
      await req.respond(Http404,"<h1>404: No such file</h1>")
      return

  echo "reading " & path

  if path[path.len-4..path.len-1] == ".css" :
    mime = "text/css"

  var headers = newHttpHeaders([("Content-Type",mime)])
 
  await req.respond(Http200, content, headers)
