/* 
(function()
{
    $.Msg("hello123")
    var container = $("#RaidStatus");
    var containerPanel = $.CreatePanel("Panel", container, {});
    containerPanel.BLoadLayoutSnippet("HeroStatus");
    var table_data = CustomNetTables.GetAllTableValues("heroes");
    $.Msg("table data ", table_data)
    $.Msg("--------------------------------------")

})();  

init - get hero data 

CustomNetTables.SubscribeNetTableListener("heroes", function(table, key, data){
    $.Msg("v2 data ", data)
});*/

function AddDebugPlayer()
{
    // make new panel
    var playerContainer = $("#PlayerContainer");
    var containerPanel = $.CreatePanel("Panel", playerContainer, {});
    containerPanel.BLoadLayoutSnippet("PlayerFrame");
}

function debug()
{  
    $.Msg("helloword")
    AddDebugPlayer()
}
 
//debug();

/*var data = CustomNetTables.GetAllTableValues("heroes")
$.Msg("------ data ------")
$.Msg(data)*/