function update(){
    onLoad();
    console.log("onLoad()");
}
$(document).ready(function(){
    $("input").each(function(){
        var id=$(this).attr("id");
        var val=Cookies.get(id);
        if(typeof(val)=="undefined") return;
        $(this).val(val);
    });
    $("input").change(function(){
        tmp=$(this);
        var id=$(this).attr("id");
        var val=$(this).val();

        Cookies.set(id,val);

        update();
    });
}); 

