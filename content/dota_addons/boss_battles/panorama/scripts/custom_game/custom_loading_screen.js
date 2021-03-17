"use strict";

(function () {

    $.Msg("hello is this js loading")

    // load the header snippet
    var leaderboardContainer_header = $("#leaderboard_titles");
    var leader_board_header_info = $.CreatePanel("Panel", leaderboardContainer_header, "");
	leader_board_header_info.BLoadLayoutSnippet("leaderboard_header_info");	

    // load row snippet
    var leaderboardContainer_row = $("#leaderboard_rows");
    var leader_board_row_info = $.CreatePanel("Panel", leaderboardContainer_row, "");
	leader_board_row_info.BLoadLayoutSnippet("leaderboard_row_info");	

})();