import os,tables,hashes,system,locks,ws,asyncdispatch,asynchttpserver,json

type cmd_t = object
    cmd: string
    arg0: string
#~var dict = newTable[string,string]()

let x_max = 2 
let y_max = 1

#let path="/home/richard/sdb6/corpus"
let path="/home/richard/proj/alpha/corpus"
var freq_prof = newTable[string,CountTable[string]]()

proc procString(data: string,xlen: int, ylen: int) = 
#    echo "{" & $xlen & "} => {" & $ylen & "}"
    for x in countup(xlen,data.len-ylen-2):
        var xs=data[x-xlen..x]  
        var ys=data[x+1..x+1+ylen]
#        echo xs & " => " & ys
        if freq_prof.hasKey(xs):
            freq_prof[xs].inc(ys)
        else:
            var e = initCountTable[string]()
            e.inc(ys)
            freq_prof[xs]=e


proc procFile(dpath: string) =
    var data=readFile(dpath)

    for x in countup(0,x_max):
        for y in countup(1,y_max):
            procString(data,x,y)
            
#            x=dpath[
            

for path in os.walkDirRec(path,{pcFile,pcLinkToFile},{pcDir,pcLinkToDir}):
#    echo path
    procFile(path)

#for comp,dir in os.walkDir(path):
#    echo dir

        
#    echo a & "=>" & b
#    echo "iterate"

#var tstCntTable = newCountTable[string]()
#tstCntTable.inc("foo")
#tstCntTable.inc("foo")
#tstCntTable.inc("bar")

#echo tstCntTable
#echo "var freqprof*=" & $freq_prof & ".toTable()"

echo "var freqprof=" & $freqprof & ".toTable[string,CountTable[string]]()"

var server = newAsyncHttpServer()

proc predict(x: string): string =
    echo "looking for " & x
    if freq_prof.hasKey(x):
        var ja = newJObject() 
        var ys=freq_prof[x]
        for y,f in ys: 
            ja.add($y,%f)
        return $ ja
    else:
        return "{}" 

proc reqcback(req: Request) {.async,gcsafe.} = 
    var ws = await newWebsocket(req)
    while ws.readyState == Open:
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
        echo cmd0 & " " & arg0
#        echo predict(arg0)
        await ws.sendPacket(predict(arg0)) 

waitFor server.serve(Port(10000),reqcback)
