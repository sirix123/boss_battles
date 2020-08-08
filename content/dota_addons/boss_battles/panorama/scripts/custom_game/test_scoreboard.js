

function scoreboardTestEvent(data)
{	
	//$.Msg( "JS scoreboardTestEvent: data =  " , data );	
	for (var i in data)
	{
		//$.Msg( "data[i] =  ", data[i] );		
		//data[i] contains values for one scoreboard row.
		//currently 2 things, playerName and Score.
		showScoreboardRow(data[i])
	}
}

//Load the ScoreboardRow snippet and the populate it with data 
function showScoreboardRow(row)
{
	$.Msg( "JS showScoreboardRow: row =  " , row );	

	var scoreboardContainer = $("#ScoreboardContainer");
	var entryPanel = $.CreatePanel("Panel", scoreboardContainer, row);
	entryPanel.BLoadLayoutSnippet("ScoreboardRow");	


	var playerNameElement = entryPanel.FindChildInLayoutFile("PlayerName")
	if (!!playerNameElement) //if not null
	{
		playerNameElement.text = row.playerName
	}

	var scoreElement = entryPanel.FindChildInLayoutFile("Score")
	if (!!scoreElement) //if not null
	{
		scoreElement.text = row.Score
	}

	//Add some css
	//panel.style[styleName] = styleValue;
}




function showScoreBoard(data)
{
	var scoreboardContainer = $("#LeaderboardContainer");
	$.Msg("showScoreBoard(data)")
	$.Msg("scoreboardContainer = ", scoreboardContainer)

	for (var d in data)
	{
		var entryPanel = $.CreatePanel("Panel", scoreboardContainer, d);
		entryPanel.BLoadLayoutSnippet("ScoreboardRow");	
	}
}


GameEvents.Subscribe( "scoreboardTestEvent", scoreboardTestEvent);



