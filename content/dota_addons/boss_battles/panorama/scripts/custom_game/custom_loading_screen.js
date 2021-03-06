"use strict";

(function () {

    // load the header snippet
    var leaderboardContainer = $("#LeaderboardContainer");
    var leader_board_header_info = $.CreatePanel("Panel", leaderboardContainer, null);
	leader_board_header_info.BLoadLayoutSnippet("leaderboard_header_info");	

})();