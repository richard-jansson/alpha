import math,gamelight/vec

proc len*(p: Point[float]): float =
    var a = Point[float](x:0.0,y:0.0)
    var dsq = a.distanceSquared(p)
    return sqrt(dsq)

proc len2*(p: Point[float]): float =
    var a = Point[float](x:0.0,y:0.0)
    var dsq = a.distanceSquared(p)
    return dsq

proc dot*(a: Point[float],b: Point[float]): float = 
    var sx=a.x*b.x
    var sy=a.y*b.y
    return sx + sy 
     
