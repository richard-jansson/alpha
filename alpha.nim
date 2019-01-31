import dom,jsconsole,gamelight/graphics

let W = 640
let H = 480

let X0= 320
let Y0 = 432
let W0 = 512
let H0 = 384 

type
    Node = ref object of RootObj
        renderer: Renderer2D
        x: int
        y: int
        w: int
        h: int

proc render(node: Node) = 
    var x,y,w,h : int

    var tw: int
    tw=int(node.w/2)
    
    x=node.x-tw
    y=node.y-node.h
    w=node.w
    h=node.h

    node.renderer.strokeRect(x,y,w,h)

#proc newNode*(renderer: Renderer2D,x: int,y: int,w: int, h: int): Node =
#    result = Node(renderer,x,y,w,h)

# Startup 
proc onLoad(event: Event) {.exportc.} =
    # paint bg white and get renderer
    var renderer=newRenderer2D("tdash",W,H)
    renderer.fillRect(0,0,W,H,"#ffffff") 
    
    # Create our root node 
    var root=Node(
        renderer: renderer,
        x: X0,
        y: Y0,
        w: W0,
        h: H0)

    root.render() 


window.onload = onLoad
