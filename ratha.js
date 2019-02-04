var ws;

function update(){
    onLoad();
    console.log("onLoad()");
}

function update_analysis(a){
    var val;
    if(typeof(a)=="undefined") val=$(this).val()
    else val=a;

    var cmd={cmd:"pred",arg0:val}
    
    ws.send(JSON.stringify(cmd));

    console.log(val);
}

function recvPred(d){
    tmp=d;
    var msg=JSON.parse(d.data)
    console.log(msg)

    var o=$("#textresult");
    o.html("");
    for(k in msg){
        var e=$("<div></div>",{class:"object"})
        var y=$("<div></div>",{class:"string"})
        var f=$("<div></div>",{class:"freq"})
        y.html(k);
        f.html("["+msg[k]+"]");
        e.append(y);
        e.append(f);
        o.append(e);
    }
    
}

function on_conn(){
    $("#con").html("connected");
    update_analysis($("input.analyze").val());
}
function on_close(){
    $("#con").html("closed");
}

$(document).ready(function(){
    $("input.ind").each(function(){
        var id=$(this).attr("id");
        var val=Cookies.get(id);
        if(typeof(val)=="undefined") return;
        $(this).val(val);
    });
    $("input.ind").change(function(){
        tmp=$(this);
        var id=$(this).attr("id");
        var val=$(this).val();

        Cookies.set(id,val);

        update();
    });
    
    ws=new WebSocket("ws://localhost:10000/ex");

    ws.onmessage=recvPred

    ws.onopen=on_conn;
    ws.onclose=on_close;

    $("input.analyze").change(update_analysis);
    $("input.analyze").keyup(update_analysis);
}); 

