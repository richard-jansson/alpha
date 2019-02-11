var ws;
var cfg={};

function update(cfg,x,y){
    if(typeof(onLoad)!="function") return;
//    console.log("onLoad()");
    var __cfg={};
    for(var k in cfg){
        var i=parseInt(cfg[k]);
        var f=parseFloat(cfg[k]);
        if(f!=NaN) __cfg[k]=f;
        else if(i!=NaN) __cfg[k]=i;
        else __cfg[k]=cfg[k];
    }
//    console.log(__cfg)
    onLoad(__cfg,x,y);
}

function get_pred(arg0){
    var cmd={cmd:"pred",arg0:arg0}
    
    ws.send(JSON.stringify(cmd));
}
function update_analysis(a){
    var val=$(this).val();
    get_pred(val);
}

function recvPred(d){
    tmp=d;
    var msg=JSON.parse(d.data)

    var o=$("#textresult");
    o.html("");
    var i=0;
    for(k in msg){
        var c=msg[k];
        var e=$("<div></div>",{class:"object"})
        var y=$("<div></div>",{class:"string"})
        var f=$("<div></div>",{class:"freq"})
        y.html(c.s);
        f.html("["+c.f+"]");
        e.append(y);
        e.append(f);
        o.append(e);
        i++;
        if(i>200) break;
    }

    console.log("DOM updated");
    
}

function on_conn(){
    $("#con").html("connected");
    get_pred($("input.analyze").val());
}
function on_close(){
    $("#con").html("closed");
}

$(document).ready(function(){
    $("input.ind").each(function(){
        var id=$(this).attr("id");
        var cval=Cookies.get(id);
        var oval=$(this).val();
        if(typeof(cval)!="undefined"){
            $(this).val(cval);
            cfg[id]=cval;
        }else{
            cfg[id]=oval;
        }
    });
    update(cfg,-1,-1);
    $("input.ind").change(function(){
        tmp=$(this);
        var id=$(this).attr("id");
        var val=$(this).val();

        Cookies.set(id,val);
        cfg[id]=val;

        update(cfg,-1,-1);
    });
    
    ws=new WebSocket("ws://localhost:10000/ex");

    ws.onmessage=recvPred

    ws.onopen=on_conn;
    ws.onclose=on_close;

    $("input.analyze").change(update_analysis);
    $("input.analyze").keyup(update_analysis);

    $("#tdash").mousemove(function(e){
//        console.log(e.offsetX + ", "+e.offsetY);
        update(cfg,e.offsetX,e.offsetY)
    })
}); 

