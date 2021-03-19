"use strict";
// andleshaker lsitener/sender
// grab data from lua handler


// run this function after a client server handshake
(function () {

    $.Msg("hello is this js loading")

    // load the header snippet
    var leaderboardContainer_header = $("#leaderboard_titles");
    var leader_board_header_info = $.CreatePanel("Panel", leaderboardContainer_header, "");
	leader_board_header_info.BLoadLayoutSnippet("leaderboard_header_info");	

    // load row snippet
    // for each index in the data collection create a row and populate it with data from that index...
    let leaderboardContainer_row = $("#leaderboard_rows");

    var tLeaders = DummyData();

    for(let i in tLeaders)
	{
        let leader_board_row_info = $.CreatePanel("Panel", leaderboardContainer_row, tLeaders[i]);
        leader_board_row_info.BLoadLayoutSnippet("leaderboard_row_info");
    
        if(i % 2 == 0)
        {
            leader_board_row_info.AddClass( "leaderboard_row_info" );
        }else
        {
            leader_board_row_info.AddClass( "leaderboard_row_info_odd" );
        }

        // rank
        var rank = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_rank")
        rank.text = tLeaders[i].rank

        // player 1
        var playerName_1 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_player_1")
        var playerHero_1 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_hero_1")
        var playerLives_1 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_live_1")
        playerName_1.text = tLeaders[i].playerData[0].name
        playerHero_1.text = tLeaders[i].playerData[0].hero
        playerLives_1.text = tLeaders[i].playerData[0].lives_remaining

        // player 2
        var playerName_2 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_player_2")
        var playerHero_2 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_hero_2")
        var playerLives_2 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_live_2")
        playerName_2.text = tLeaders[i].playerData[1].name
        playerHero_2.text = tLeaders[i].playerData[1].hero
        playerLives_2.text = tLeaders[i].playerData[1].lives_remaining

        // player 3
        var playerName_3 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_player_3")
        var playerHero_3 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_hero_3")
        var playerLives_3 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_live_3")
        playerName_3.text = tLeaders[i].playerData[2].name
        playerHero_3.text = tLeaders[i].playerData[2].hero
        playerLives_3.text = tLeaders[i].playerData[2].lives_remaining

        // player 4
        var playerName_4 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_player_4")
        var playerHero_4 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_hero_4")
        var playerLives_4 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_live_4")
        playerName_4.text = tLeaders[i].playerData[3].name
        playerHero_4.text = tLeaders[i].playerData[3].hero
        playerLives_4.text = tLeaders[i].playerData[3].lives_remaining

        // boss times
        var bosstime_1 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_1_time")
        bosstime_1.text = tLeaders[i].boss_1_time

        var bosstime_2 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_2_time")
        bosstime_2.text = tLeaders[i].boss_2_time

        var bosstime_3 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_3_time")
        bosstime_3.text = tLeaders[i].boss_3_time

        var bosstime_4 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_4_time")
        bosstime_4.text = tLeaders[i].boss_4_time

        var bosstime_5 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_5_time")
        bosstime_5.text = tLeaders[i].boss_5_time

        var bosstime_6 = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_6_time")
        bosstime_6.text = tLeaders[i].boss_6_time

        var bosstime_total = leader_board_row_info.FindChildInLayoutFile("leaderboard_row_info_boss_total_time")
        bosstime_total.text = tLeaders[i].boss_total_time


        $.Msg("tLeaders[i] ",tLeaders[i])   
	}

})();


// dummy session data object
function DummyData()
{
    let top10 = []
    var nRanks = 10
    for (var i = 0; i < nRanks; i++  )
	{
        top10[i] = 
        {
            "rank": i + 1,
            "playerData":
                [
                    {
                        "name": "Stefan",
                        "hero": "Fire Mage",
                        "lives_remaining": "3"
                    },
                
                    {
                        "name": "Marc",
                        "hero": "Ice Mage",
                        "lives_remaining": "0"
                    },

                    {
                        "name": "Mike",
                        "hero": "Purple Mage",
                        "lives_remaining": "1"
                    },
                
                    {
                        "name": "Ryan",
                        "hero": "Palla",
                        "lives_remaining": "2"
                    }
                ],

            "boss_1_time": "30:00",
            "boss_2_time": "23:00",
            "boss_3_time": "00:10",
            "boss_4_time": "30:20",
            "boss_5_time": "30:60",
            "boss_6_time": "90:00",
            "boss_total_time": "01:30:00"
        }
    }

    //$.Msg("top10 ",top10)
    return top10
}


    /*
        collection structure

        top 10
        [
            {
                "rank": 1,
                "playerData":
                    [
                        {
                            "name": "Stefan",
                            "hero": "Ice Mage",
                            "lives_remaining": "3"
                        },
                    
                        {
                            "name": "Stefan",
                            "hero": "Ice Mage",
                            "lives_remaining": "3"
                        },

                        {
                            "name": "Stefan",
                            "hero": "Ice Mage",
                            "lives_remaining": "3"
                        },
                    
                        {
                            "name": "Stefan",
                            "hero": "Ice Mage",
                            "lives_remaining": "3"
                        }
                    ],

                "boss_1_time": "30:00",
                "boss_2_time": "30:00",
                "boss_3_time": "30:00",
                "boss_4_time": "30:00",
                "boss_5_time": "30:00",
                "boss_6_time": "30:00",
                "boss_total_time": "01:30:00"
            },

            {},
            {},
            ...10
        ]

    */