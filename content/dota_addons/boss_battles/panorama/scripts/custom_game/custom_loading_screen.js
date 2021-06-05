"use strict";

/* buttons for leaderboard to link */
function OnSocialButtonOnePressed(){
    $.Msg("click social button 1 website");

    //$.DispatchEvent("ExternalBrowserGoToURL", "your_url");
    $.DispatchEvent("ExternalBrowserGoToURL", "https://www.bossbattles.co");

}

function OnSocialButtonTwoPressed(){
    $.Msg("click social button 2 discord ");
    $.DispatchEvent("ExternalBrowserGoToURL", "https://discord.gg/ba82ZtATmH");
}

function OnSocialButtonThreePressed(){
    $.Msg("click social button 3 pateron");
    $.DispatchEvent("ExternalBrowserGoToURL", "https://www.patreon.com"); 
}


let top10panels = {};
let normal_mode_data = null;
let hard_mode_data = null;

let leaderboard_buttons_container = $("#LeaderboardContainer");

let normalDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_1");
normalDataButton.AddClass( "leaderboard_buttons" );

let hardDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_2");
hardDataButton.AddClass( "leaderboard_buttons" );

/* buttons for leaderboard to load different data*/
function OnNormalButtonPressed(){
    $.Msg("click normal button ");
    normalDataButton.RemoveClass( "disabled" );

    if (normal_mode_data){
        $.Msg("click normal button ", normal_mode_data);
        normalDataButton.AddClass( "enable" );
        hardDataButton.RemoveClass( "enable" );
        hardDataButton.AddClass( "disabled" );
        UpdateScoreboardRows( normal_mode_data );
    }
}

function OnHardButtonPressed(){
    $.Msg("click hard button ");
    hardDataButton.RemoveClass( "disabled" );

    if (hard_mode_data){
        $.Msg("click hard button ", hard_mode_data);
        hardDataButton.AddClass( "enable" );
        normalDataButton.RemoveClass( "enable" );
        normalDataButton.AddClass( "disabled" );
        UpdateScoreboardRows( hard_mode_data );
    }
}

/* recieve event from server*/
function CreateLeaderBoard( data ) {
	//$.Msg("server event handshake", data);
    normal_mode_data = data;
    hard_mode_data = data;

    hardDataButton.AddClass( "enable" );
    hardDataButton.RemoveClass( "disabled" );

    normalDataButton.AddClass( "disabled" );
    normalDataButton.RemoveClass( "enable" );

    if (hard_mode_data){
        UpdateScoreboardRows( hard_mode_data );

        // delete the leader board loading panel
        $('#LoadingScreenLeaderBoard').DeleteAsync( 0.0 );
    }
}

(function () {

    // for website and discord
    var leaderboardContainer_header = $("#leaderboard_titles");
    var leader_board_header_info = $.CreatePanel("Panel", leaderboardContainer_header, "");
	leader_board_header_info.BLoadLayoutSnippet("leaderboard_header_info");	

    // for top 10 leaderboard
    let leaderboardContainer_row = $("#leaderboard_rows");

    for (let i=1; i < 12; i++) // why does this need to be 12 to populate 10 ranks..?
	{
        let leader_board_row_info = $.CreatePanel("Panel", leaderboardContainer_row, i);
        leader_board_row_info.BLoadLayoutSnippet("leaderboard_row_info");
        top10panels[i] = leader_board_row_info; 

        if(i % 2 == 0)
        {
            leader_board_row_info.AddClass( "leaderboard_row_info" );
        }else
        {
            leader_board_row_info.AddClass( "leaderboard_row_info_odd" );
        }
    }

})();


function UpdateScoreboardRows( data )
{
    //$.Msg("UpdateScoreboardRows( data )")
    //$.Msg("data = ", data)
    //$.Msg("data[games] = ", data["games"])

    //for each row in the leaderboard
    for (var index in data["games"]) {
        let leaderboardRow = top10panels[index];
        var rank = leaderboardRow.FindChildTraverse("leaderboard_row_info_rank").text = index+ToOrdinal(index)

        var totalTime = leaderboardRow.FindChildTraverse("leaderboard_row_info_total_time").text = data["games"][index]["total_time"]

        for(var bossTimeIndex in data["games"][index]["boss_times"])
        {
            //$.Msg("bossRow = ", data["games"][index]["boss_times"][bossTimeIndex])
            //bossRow = {"boss_name":"Tinker","time_taken":"4:59"}
            leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_"+bossTimeIndex+"_time").text = data["games"][index]["boss_times"][bossTimeIndex]["time_taken"]
        }

        for(var playerIndex in data["games"][index]["players"])
        {
            //$.Msg("playerRow = ", data["games"][index]["players"][playerIndex])
            //playerRow = {"lives":1,"player_name":"Moomoo","hero":"ranger"}
            leaderboardRow.FindChildTraverse("leaderboard_row_info_player_"+playerIndex).text = data["games"][index]["players"][playerIndex]["player_name"]
            leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_"+playerIndex).text = data["games"][index]["players"][playerIndex]["hero"]
            leaderboardRow.FindChildTraverse("leaderboard_row_info_live_"+playerIndex).text = data["games"][index]["players"][playerIndex]["lives"]
        }
    }
}

function ToOrdinal(number)
{
    // Start with the most common extension.
    let extension = "th";
    // Examine the last 2 digits.
    let last_digits = number % 100;
    if (last_digits < 11 || last_digits > 13)
    {
        // Check the last digit.
        switch (last_digits % 10)
        {
            case 1:
                extension = "st";
                break;
            case 2:
                extension = "nd";
                break;
            case 3:
                extension = "rd";
                break;
        }
    }
    return extension;

}


// get data
GameEvents.Subscribe( "loading_screen_data", CreateLeaderBoard );

