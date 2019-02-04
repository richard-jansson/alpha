import os,tables,hashes,system,locks

    
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
