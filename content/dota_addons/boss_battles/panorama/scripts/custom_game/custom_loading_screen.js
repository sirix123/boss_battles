"use strict";

/* buttons for leaderboard to link */
function OnSocialButtonOnePressed(){
    $.Msg("click social button 1 website");

    //$.DispatchEvent("ExternalBrowserGoToURL", "your_url");
    $.DispatchEvent("ExternalBrowserGoToURL", "https://bossbattles.co/Leaderboard");

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
let easy_mode_data = null;

let leaderboard_buttons_container = $("#LeaderboardContainer");

let normalDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_1");
normalDataButton.AddClass( "leaderboard_buttons" );

let hardDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_2");
hardDataButton.AddClass( "leaderboard_buttons" );

let easyDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_3");
easyDataButton.AddClass( "leaderboard_buttons" );


/* buttons for leaderboard to load different data*/
function OnNormalButtonPressed(){
    //$.Msg("click normal button ");
    normalDataButton.RemoveClass( "disabled" );
    normalDataButton.AddClass( "enable" );

    hardDataButton.RemoveClass( "enable" );
    hardDataButton.AddClass( "disabled" );

    easyDataButton.RemoveClass( "enable" );
    easyDataButton.AddClass( "disabled" );

    ClearScoreboardRows();
    UpdateScoreboardRows( normal_mode_data );
}

function OnHardButtonPressed(){
    //$.Msg("click hard button ");
    hardDataButton.RemoveClass( "disabled" );
    hardDataButton.AddClass( "enable" );

    normalDataButton.RemoveClass( "enable" );
    normalDataButton.AddClass( "disabled" );

    easyDataButton.RemoveClass( "enable" );
    easyDataButton.AddClass( "disabled" );

    ClearScoreboardRows();
    UpdateScoreboardRows( hard_mode_data );
}

function OnEasyButtonPressed(){
    //$.Msg("click easy button ");
    easyDataButton.RemoveClass( "disabled" );
    easyDataButton.AddClass( "enable" );

    normalDataButton.RemoveClass( "enable" );
    normalDataButton.AddClass( "disabled" );

    hardDataButton.RemoveClass( "enable" );
    hardDataButton.AddClass( "disabled" );

    ClearScoreboardRows();
    UpdateScoreboardRows( easy_mode_data );
}


/* recieve event from server*/
function CreateLeaderBoard( data ) {
    $.Msg("CreateLeaderBoard( data )",data);
    //data data for both game modes
    normal_mode_data = data[2];
    hard_mode_data = data[3];
    easy_mode_data = data[1];

    hardDataButton.AddClass( "disabled" );
    hardDataButton.RemoveClass( "enable" );

    normalDataButton.AddClass( "disabled" );
    normalDataButton.RemoveClass( "enable" );

    easyDataButton.RemoveClass( "disabled" );
    easyDataButton.AddClass( "enable" );

    if (easy_mode_data){
        ClearScoreboardRows();
        UpdateScoreboardRows( easy_mode_data );

        // delete the leader board loading panel
        $('#LoadingScreenLeaderBoard').DeleteAsync( 0.0 );
    }
}

// (function () {

//     // for website and discord
//     var leaderboardContainer_header = $("#leaderboard_titles");
//     var leader_board_header_info = $.CreatePanel("Panel", leaderboardContainer_header, "");
// 	leader_board_header_info.BLoadLayoutSnippet("leaderboard_header_info");	

//     // for top 10 leaderboard
//     let leaderboardContainer_row = $("#leaderboard_rows");

//     for (let i=1; i < 12; i++)
// 	{
//         let leader_board_row_info = $.CreatePanel("Panel", leaderboardContainer_row, i);
//         leader_board_row_info.BLoadLayoutSnippet("leaderboard_row_info");
//         top10panels[i] = leader_board_row_info; 

//         if(i % 2 == 0)
//         {
//             leader_board_row_info.AddClass( "leaderboard_row_info" );
//         }else
//         {
//             leader_board_row_info.AddClass( "leaderboard_row_info_odd" );
//         }
//     }

// })();


function ClearScoreboardRows()
{
    //for (var i = 0; i <= 10; i++) {
    //same loop as used above... 
    for (let i=1; i < 12; i++) {
        let leaderboardRow = top10panels[i];
        
        leaderboardRow.FindChildTraverse("leaderboard_row_info_rank").text = i+ToOrdinal(i);
        leaderboardRow.FindChildTraverse("leaderboard_row_info_total_time").text = "";

        for (let b=1; b <= 6; b++) {
            leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_"+b+"_time").text = ""
        }

        for (let p=1; p <= 4; p++) {
            leaderboardRow.FindChildTraverse("leaderboard_row_info_player_"+p).text = ""
            leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_"+p).text = ""
            leaderboardRow.FindChildTraverse("leaderboard_row_info_live_"+p).text = ""
        }
    }   
}


function UpdateScoreboardRows( data )
{
    //$.Msg("UpdateScoreboardRows( data )")
    //$.Msg("data = ", data)
    //$.Msg("data[games] = ", data["games"])

    //for each row in the leaderboard
    for (var index in data["games"]) {

        let leaderboardRow = top10panels[index];
        leaderboardRow.FindChildTraverse("leaderboard_row_info_rank").text = index+ToOrdinal(index)
        leaderboardRow.FindChildTraverse("leaderboard_row_info_total_time").text = data["games"][index]["total_time"]

        for(var bossTimeIndex in data["games"][index]["boss_times"])
        {
            //bossRow = {"boss_name":"Tinker","time_taken":"4:59"}
            leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_"+bossTimeIndex+"_time").text = data["games"][index]["boss_times"][bossTimeIndex]["time_taken"]
        }

        for(var playerIndex in data["games"][index]["players"])
        {
            //playerRow = {"lives":1,"player_name":"Moomoo","hero":"ranger"}
            leaderboardRow.FindChildTraverse("leaderboard_row_info_player_"+playerIndex).text = data["games"][index]["players"][playerIndex]["player_name"]
            leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_"+playerIndex).text = data["games"][index]["players"][playerIndex]["hero"]
            leaderboardRow.FindChildTraverse("leaderboard_row_info_live_"+playerIndex).text = data["games"][index]["players"][playerIndex]["deaths"]
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
// GameEvents.Subscribe( "loading_screen_data", CreateLeaderBoard );

