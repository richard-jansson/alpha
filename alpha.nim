import dom,jsconsole,gamelight/[graphics,vec],jsffi,math,amath

let W = 640
let H = 480

let X0= 320
let Y0 = 432
let W0 = 512
let H0 = 384 

var mx = -1
var my = -1

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
        k: float
        depth: int

proc render(node: Node) = 
    if(node.depth>3):
        return

#    console.log(node.depth)

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

    var k: float
    k=node.k

#    console.log("r=" & $r)
#    console.log("k=" & $k)

#    console.log(ao)

# offset angle / phase in rad
    var o = degToRad(float(ao))
    var fov = degToRad(float(node.fovo))
    var afov = degToRad(float(node.fovoa))
    var bfov = degToRad(float(node.fovob))

    var ax=o

    var da=afov/float(N)
    var db=bfov/float(M)

#    console.log(o)
    var u = Point[float](x:float(0-r),y: float(0)) 
   
#    console.log(u)
    u=u.rotate(float(o),Point[float](x:0,y:0))

    var p0= Point[float](x:float(node.x),y:float(node.y))
    var p1= Point[float](x:float(node.x),y:float(node.y))

    p1 = p1 + u

#    console.log($u)
#    console.log($p0)
#    console.log($p1)
  
    node.renderer.strokeLine(p0,p1)
    
#    console.log(N)
#    console.log(node.w)
# Draw leaves
    var i:int = 0
    while i < N:
#        console.log(i)
        var pa=p0+u 
        ax=ax+da
        u=u.rotate(float(da),Point[float](x:0,y:0))
        var pb=p0+u
        node.renderer.strokeLine(pa,pb)
        inc(i)
        if i==N:
            break
        u=u.rotate(float(db/2),Point[float](x:0,y:0))
        ax=ax+db/2-fov/2
        # next node
        var pbr=p0+u
        var u0=u
        var a0=u.angle()+180
#        console.log(a0)
        u=u.rotate(float(db/2),Point[float](x:0,y:0))
        ax=ax+db/2
        var pc=p0+u
        var w=sqrt(pb.distanceSquared(pc))
#        console.log("r=" & $node.r)
#        console.log("k=" & $node.k)
        var k=1.0
        var tr=float(node.r)/k
#        console.log(tr)

# Calculate coef 
        var realc=Point[float](x:float(mx),y:float(my))
        var cv=realc-p0
        
        var t = cv.dot(u0) 
        var s = t / u0.len2()
        var cp = u0 * s

        if s > 0 :
            node.renderer.strokeLine(p0,p0+cv)
            node.renderer.strokeLine(p0,p0+cp)
        
#        node.renderer.strokeLine(p0,pbr)

        var branch=Node(
            renderer:node.renderer,
            x: int(pbr.x), y:int(pbr.y),
            w: int(w),h: int(w),
            ao: int(a0-node.fovo/2),
            r: int(float(node.r)/node.k),
            N: node.N,M:node.M,
            fovo: node.fovo,fovoa: node.fovoa,fovob: node.fovob,
            k: node.k,
            depth: node.depth+1)
        branch.render()
   
    p1=p0+u
    node.renderer.strokeLine(p0,p1)
        

#    node.renderer.strokeRect(x,y,w,h)

#proc newNode*(renderer: Renderer2D,x: int,y: int,w: int, h: int): Node =
#    result = Node(renderer,x,y,w,h)


# Startup 
proc onLoad(cfg: JsObject, x: int, y: int) {.exportc.} =
#    console.log($x & "," & $y)
    mx = x
    my = y
    # paint bg white and get renderer
    var renderer=newRenderer2D("tdash",W,H)
    renderer.fillRect(0,0,W,H,"#ffffff") 

#[
    for k,v in cfg:
        console.log(k);
    for k,v in cfg:
        console.log(v)
    for k,v in cfg:
        console.log(k)
        console.log(v)
]#

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
        fovob: cfg.fov_branches.to(int),
        k: cfg.k.to(float),
        depth: 1
        )

    root.render() 


#window.onload = onLoad
