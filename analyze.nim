import os,tables,hashes,system

var dict = newTable[string,string]()

let x_max = 4 
let y_max = 2

let path="/home/richard/sdb6/corpus"

proc procString(data: string,xlen: int, ylen: int) = 
#    echo "{" & $xlen & "} => {" & $ylen & "}"
    for x in countup(xlen,data.len-ylen-2):
        var xs=data[x-xlen..x]  
        var ys=data[x+1..x+1+ylen]
#        echo xs & " => " & ys

proc procFile(dpath: string) =
    var data=readFile(dpath)

    for x in countup(0,x_max):
        for y in countup(1,y_max):
            procString(data,x,y)
            
#            x=dpath[
            

for dpath in os.walkDirRec(path,{pcFile,pcLinkToFile},{pcDir,pcLinkToDir}):
#    dict[path]="value"
#    echo "reading " & path
#    var data=readFile(path)
#    echo $data.len
    echo dpath
    procFile(dpath)

for a,b in dict:
    echo a & "=>" & b
#    echo "iterate"
