# Handles audio recording and translation to notes

# C interfaces
import alsareci,ffti,getnotei
# others 
#import channels
import os
# local
import vac

let SAMPLES = 10
let WINDOW = 4096

var i = 0

var buf = init_rec(cint(WINDOW))
var r,f: cint
var note : ptr note_t

var ch: Channel[string]

proc coltrane_init*(): ptr Channel[string] =
  ch.open()
  setup_fft(cint(WINDOW))
  return ch.addr

proc coltrane_do*()  =
  while true:
     r=rec()
     f=do_fft(cast[ptr int16](buf))
     inc(i)
     if f < 0:
       continue 
     note = getnote_note(f)
     var s: string = $cast[cstring](note.lname.addr)
     echo "in coltrane: " & s

     getnote_freenote(note)
     ch.send(s)
#     vac_broadcast(s)

proc coltrane_cleanup*() =
  discard close_rec()
  destroy_fft()
