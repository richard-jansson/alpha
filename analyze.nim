import os,tables,hashes,system,locks,ws,asyncdispatch,asynchttpserver,json,sequtils,algorithm

type cmd_t = object
    cmd: string
    arg0: string

type Entry = tuple[x: string, f: float64]

proc compEntry(x: Entry, y: Entry): int = 
    if x.f == y.f:
        return 0
    if x.f > y.f:
        return 1
    else:
        return -1 

#~var dict = newTable[string,string]()

let x_max = 6 
let y_max = 4
var e_dropoff = 2.71828

#let path="/home/richard/sdb6/corpus"
let path="/home/richard/proj/alpha/corpus"
var freq_prof = newTable[string,CountTable[string]]()

proc procString(data: string,xlen: int, ylen: int) = 
#    echo "{" & $xlen & "} => {" & $ylen & "}"
    for x in countup(xlen,data.len-ylen-2):
        var xs: string
        if xlen == 0: 
            xs=""
        else: 
            xs=data[x-xlen..x-1]  
        var ys=data[x..x+ylen-1]
#        echo "[" & xs & "] => " & ys
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

proc predict(xs: string): string =
    echo "looking for [" & xs & "]"
    var ja = newJObject() 
    var resp : seq[Entry]

    var l_max = x_max


    if xs.len < x_max:
        l_max = xs.len
    
    echo "0 -> " & $l_max
    echo "slen: " & $xs.len

    var mult : float64 = 1

    for l in countup(0,l_max):
        echo $l & "/" & $l_max
        var x: string
        if l == 0:
            x=""
        else:
            x=xs[xs.len-l..xs.len-1]
        echo "matching against: [" & x & "]"

        if freq_prof.hasKey(x):
            var ys=freq_prof[x]
            for y,f in ys: 
                var f0= float(f)*mult
                var e: Entry = (y,f0)
                resp.insert(e)
#                ja.add($y,%f0)
        mult= mult * e_dropoff
#    echo ja
    echo "sorting"
    sort(resp,compEntry,SortOrder.Descending)
    echo "sorting done"
    var i = 0 
    for k in resp:
        var y: string 
        var f: float64
        y=k.x
        f=k.f
        if i > 20:
            break
        ja.add($y,% f)
        inc(i)

    echo $ja

    return $ ja
#    return "{}"

proc reqcback(req: Request) {.async,gcsafe.} = 
    var ws = await newWebsocket(req)
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
            echo cmd0 & " " & arg0
    #        echo predict(arg0)
            try:
                await ws.sendPacket(predict(arg0)) 
            except: 
                echo "failed to send"
        except: 
            echo "failed to wait"

waitFor server.serve(Port(10000),reqcback)
