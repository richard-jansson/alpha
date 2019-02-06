import dom,jsconsole,gamelight/[graphics,vec],jsffi,math

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
        ao: int
        r: int
        N: int
        M: int
        fovo: int
        fovoa: int
        fovob: int


proc render(node: Node) = 
    var x,y,w,h,ao,r,N,M: int

    var tw: int
    tw=int(node.w/2)
    
    x=node.x-tw
    y=node.y-node.h
    w=node.w
    h=node.h
    ao=node.ao
    r=node.r
    N=node.N
    M=node.M

    console.log(ao)

# offset angle / phase in rad
    var o = degToRad(float(ao))
    var fov = degToRad(float(node.fovo))
    var afov = degToRad(float(node.fovoa))
    var bfov = degToRad(float(node.fovob))

    var da=afov/float(N)
    var db=bfov/float(M)

    console.log(o)
    var u = Point[float](x:float(0-r),y: float(0)) 
   
    console.log(u)
    u=u.rotate(float(o),Point[float](x:0,y:0))

    var p0= Point[float](x:float(node.x),y:float(node.y))
    var p1= Point[float](x:float(node.x),y:float(node.y))

    p1 = p1 + u

    console.log($u)
    console.log($p0)
    console.log($p1)
  
    node.renderer.strokeLine(p0,p1)
    
    console.log(N)
# Draw leaves
    var i:int = 0
    while i < N:
        console.log(i)
        var pa=p0+u 
        u=u.rotate(float(da),Point[float](x:0,y:0))
        var pb=p0+u
        node.renderer.strokeLine(pa,pb)
        inc(i)
        if i==N:
            break
        u=u.rotate(float(db/2),Point[float](x:0,y:0))
        # next node
        u=u.rotate(float(db/2),Point[float](x:0,y:0))
   
    p1=p0+u
    node.renderer.strokeLine(p0,p1)

        

#    node.renderer.strokeRect(x,y,w,h)

#proc newNode*(renderer: Renderer2D,x: int,y: int,w: int, h: int): Node =
#    result = Node(renderer,x,y,w,h)


# Startup 
proc onLoad(cfg: JsObject) {.exportc.} =
    # paint bg white and get renderer
    var renderer=newRenderer2D("tdash",W,H)
    renderer.fillRect(0,0,W,H,"#ffffff") 

#[
    for k,v in cfg:
        console.log(k);
    for k,v in cfg:
        console.log(v)
]#
    for k,v in cfg:
        console.log(k)
        console.log(v)

#    var ao : int 
#    console.log(cfg.offset.jsTypeOf())
#    ao = int(cfg.offset)
    
    # Create our root node 
    var root=Node(
        renderer: renderer,
        x: X0,
        y: Y0,
        w: W0,
        h: H0,
        ao: cfg.offset.to(int),
        r: cfg.r.to(int),
        N: cfg.leaves.to(int),
        M: cfg.branches.to(int),
        fovo: cfg.fov.to(int),
        fovoa: cfg.fov_leaves.to(int),
        fovob: cfg.fov_branches.to(int)
        )

    root.render() 


#window.onload = onLoad
