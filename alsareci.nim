{.compile: "alsarec.c".}
{.passC: gorge("pkg-config --cflags alsa").}
{.passL: gorge("pkg-config --libs alsa").}

proc init_rec*(n_samples: cint): ptr cuchar {.cdecl,importc:"init_rec".}
proc rec*(): cint {.cdecl,importc:"rec".}
proc close_rec*(): cint {.cdecl,importc:"close_rec".}
