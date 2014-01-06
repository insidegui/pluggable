MakeRed_menuCallback = function()
{
    var color = {"red":1,"green":0,"blue":0,"alpha":1}
    setTextColor(color)
}

MakeRed = function()
{
    Pluggable.log("MakeRed installed")
    
    Pluggable.installPluginMenuItem({
        "title" : "Make stuff red",
        "tag" : 0,
        "keyEquivalent" : "",
        "callback" : "MakeRed_menuCallback"
    });
}