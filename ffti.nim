import ospaths
const cwd =  currentSourcePath.splitFile.dir
const fftdir = cwd/"ext"/"kissfft"

{.compile: "fft.c".}
{.compile: "kiss_fftr.c".}

{.passC: "-I" & fftdir & " -I" & fftdir/"tools" }
{.passL: "-L" & fftdir & " -lkissfft -lm".}

proc setup_fft*(len: cint) {.cdecl,importc:"setup_fft".}
proc do_fft*(inp: ptr int16): cint {.cdecl,importc:"do_fft".}
proc destroy_fft*() {.cdecl,importc:"destroy_fft".}
