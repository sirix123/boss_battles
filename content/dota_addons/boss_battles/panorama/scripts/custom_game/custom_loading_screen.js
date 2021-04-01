"use strict";

let top10panels = {};
let normal_mode_data = null;
let hard_mode_data = null;

let leaderboard_buttons_container = $("#LeaderboardContainer");

let normalDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_1");
normalDataButton.AddClass( "leaderboard_buttons" );

let hardDataButton = leaderboard_buttons_container.FindChildInLayoutFile("leaderboard_button_mode_2");
hardDataButton.AddClass( "leaderboard_buttons" );

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
    let leaderboardContainer_row = $("#leaderboard_rows");

    // populate the panels with leaderboard information
    for (let i=1; i < leaderboardContainer_row.GetChildCount(); i++)
    {
        // leader board row 
        let leaderboardRow = top10panels[i];

        if ( data[i] == leaderboardRow.id ); 
        {

            // rank
            var rank = leaderboardRow.FindChildTraverse("leaderboard_row_info_rank")
            rank.text = data[i].rank

            // player 1
            var playerName_1 = leaderboardRow.FindChildTraverse("leaderboard_row_info_player_1")
            var playerHero_1 = leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_1")
            var playerLives_1 = leaderboardRow.FindChildTraverse("leaderboard_row_info_live_1")
            playerName_1.text = data[i].playerData[1].name
            playerHero_1.text = data[i].playerData[1].hero
            playerLives_1.text = data[i].playerData[1].lives_remaining

            // player 2
            var playerName_2 = leaderboardRow.FindChildTraverse("leaderboard_row_info_player_2")
            var playerHero_2 = leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_2")
            var playerLives_2 = leaderboardRow.FindChildTraverse("leaderboard_row_info_live_2")
            playerName_2.text = data[i].playerData[2].name
            playerHero_2.text = data[i].playerData[2].hero
            playerLives_2.text = data[i].playerData[2].lives_remaining

            // player 3
            var playerName_3 = leaderboardRow.FindChildTraverse("leaderboard_row_info_player_3")
            var playerHero_3 = leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_3")
            var playerLives_3 = leaderboardRow.FindChildTraverse("leaderboard_row_info_live_3")
            playerName_3.text = data[i].playerData[3].name
            playerHero_3.text = data[i].playerData[3].hero
            playerLives_3.text = data[i].playerData[3].lives_remaining

            // player 4
            var playerName_4 = leaderboardRow.FindChildTraverse("leaderboard_row_info_player_4")
            var playerHero_4 = leaderboardRow.FindChildTraverse("leaderboard_row_info_hero_4")
            var playerLives_4 = leaderboardRow.FindChildTraverse("leaderboard_row_info_live_4")
            playerName_4.text = data[i].playerData[4].name
            playerHero_4.text = data[i].playerData[4].hero
            playerLives_4.text = data[i].playerData[4].lives_remaining

            // boss times
            var bosstime_1 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_1_time")
            bosstime_1.text = data[i].boss_1_time

            var bosstime_2 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_2_time")
            bosstime_2.text = data[i].boss_2_time

            var bosstime_3 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_3_time")
            bosstime_3.text = data[i].boss_3_time

            var bosstime_4 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_4_time")
            bosstime_4.text = data[i].boss_4_time

            var bosstime_5 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_5_time")
            bosstime_5.text = data[i].boss_5_time

            var bosstime_6 = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_6_time")
            bosstime_6.text = data[i].boss_6_time

            var bosstime_total = leaderboardRow.FindChildTraverse("leaderboard_row_info_boss_total_time")
            bosstime_total.text = data[i].boss_total_time
        }
        //$.Msg("data[i] ",data[i])   
    }
}

// get data
GameEvents.Subscribe( "loading_screen_data", CreateLeaderBoard );

