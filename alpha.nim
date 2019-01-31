import dom, jsconsole

proc onLoad(event: Event) {.exportc.} =
    console.log("hi")

window.onload = onLoad
