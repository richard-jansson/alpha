import os,tables,hashes,system,locks,ws,asyncdispatch,asynchttpserver,json,sequtils,algorithm,times

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

let x_max = 12 
let y_max = 2
var e_dropoff = 2.71828*12
var resp_mlen = 128

#let path="/home/richard/sdb6/corpus"
#let path="/home/richard/proj/alpha/corpus"
let path="/var/www/html/alpha/corpus"
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
            

var t0=cpuTime()
for path in os.walkDirRec(path,{pcFile,pcLinkToFile},{pcDir,pcLinkToDir}):
#    echo path
    procFile(path)

var t=cpuTime()-t0
echo "gather profile in: "
echo t

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

#echo "var freqprof=" & $freqprof & ".toTable[string,CountTable[string]]()"

var server = newAsyncHttpServer()

proc predict(xs: string): string =
    echo "looking for [" & xs & "]"
    var t0 = cpuTime()
    var ja = newJObject() 
    var resp : seq[Entry]
    var respt = newTable[string,float]() 


    var l_max = x_max


    if xs.len < x_max:
        l_max = xs.len
    
#    echo "0 -> " & $l_max
#    echo "slen: " & $xs.len

    var mult : float64 = 1

    for l in countup(0,l_max):
#        echo $l & "/" & $l_max
        var x: string
        if l == 0:
            x=""
        else:
            x=xs[xs.len-l..xs.len-1]

        if freq_prof.hasKey(x):
            for y,f in freq_prof[x]: 
                var f0= float(f)*mult
                if respt.hasKey(y) : 
                    var fe=respt[y]
                    if f0 > fe: 
                        respt[y]=f0
                else :
                    respt[y]=f0

#                var e: Entry = (y,f0)
#                resp.add(e)
        mult= mult * e_dropoff
        
#        var t=cpuTime()-t0
#        echo t

    for y,f in respt:
        var e: Entry = (y,f)
        resp.add(e)
    
    sort(resp,compEntry,SortOrder.Descending)

    var jres = newJArray()
    
    var i = 0 
    for k in resp:
        var y: string 
        var f: float64
        y=k.x
        f=k.f
        var jel=newJObject()

        jel.add("s",% y)
        jel.add("f",% f)
        jres.add(jel)
        
#        ja.add($y,% f)
        inc(i)
        if i == resp_mlen:
            break

    echo "analysis done"
    var dt = cpuTime()-t0
    echo dt

    return $ jres
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
                var tp0=cpuTime();
#                var pres="{\"the\":1000,\"a\":700,\"b\":500}"
#                var pres=predict(arg0)
#                echo "prediction in"
                var dt = cpuTime()-tp0
#                echo dt
                await ws.sendPacket(predict(arg0)) 
#                await ws.sendPacket(pres) 
            except: 
                echo "failed to send"
        except: 
            echo "failed to wait"

waitFor server.serve(Port(10000),reqcback)

#echo "iterating over empty set"
#var tfpa0=cpuTime()
#var null = freq_prof[""]
#var resp : seq[Entry]
#for y,f in freq_prof[""]:
#    var e: Entry=(y,float(f))
#    resp.add(e)
#
#echo resp
#sort(resp,compEntry,SortOrder.Descending)
#var dtfpa0=cpuTime()-tfpa0
#echo resp
#echo dtfpa0

#echo predict("some");
#echo predict("th");
#echo predict("Wh");
#echo predict("fu");
