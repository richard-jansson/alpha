{.compile:"getnote.c".}
type
  note_t* {.bycopy.} = object
    sname*: array[3, cchar]
    lname*: array[7, cchar]
    f*: cint
    n*: cint
    i*: cint

proc getnote_note*(f: cint): ptr note_t {.cdecl,importc:"getnote_note".}
proc getnote_freenote*(n: ptr note_t) {.cdecl,importc:"getnote_freenote".}
