function update(){
    onLoad();
    console.log("onLoad()");
}

function update_analysis(){
    var val=$(this).val()

    console.log(val);
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


    $("input.analyze").change(update_analysis);
    $("input.analyze").keydown(update_analysis);
}); 

