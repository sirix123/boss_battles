

function updateScoreboardData(data)
{	
	$.Msg( "JS scoreboardTestEvent: data =  " , data );	
	for (var i in data)
	{
		//data[i] contains values for one scoreboard row.
		//currently 2 things, playerName and Score.
		setScoreboardText(data[i])
		//$.Msg( "data[i] =  ", data[i] );		
	}
}

//Load the setScoreboardText snippet and the populate it with data 
function setScoreboardText(row)
{
	//$.Msg( "JS setScoreboardText: row =  " , row );	
	var scoreboardContainer = $("#ScoreboardContainer");
	$.Msg( "JS scoreboardContainer = ", scoreboardContainer);
	if (scoreboardContainer) 
	{
		//Add text from row into various UI elements	
		var entryPanel = $.CreatePanel("Panel", scoreboardContainer, row);
		entryPanel.BLoadLayoutSnippet("ScoreboardRow");	

		var playerNameElement = entryPanel.FindChildInLayoutFile("PlayerName")
		if (!!playerNameElement) //if not null, set text
			playerNameElement.text = row.playerName

		var scoreElement = entryPanel.FindChildInLayoutFile("Score")
		if (!!scoreElement) //if not null, set text
		{
			scoreElement.text = row.Score
		}
	}
	else 
		$.Msg( "scoreboardContainer is null. Returning");	
}


function hideScoreboardUI()
{
	$.Msg( "hideScoreboardUI called");
	
	var scoreboardContainer = $("#ScoreboardContainer");
	if (scoreboardContainer) 
	{
		$.Msg( "scoreboardContainer not null");
		$.Msg( "scoreboardContainer.style.visibility = ", scoreboardContainer.style.visibility);
		scoreboardContainer.style.visibility = "collapse";
	}
	else 
		$.Msg( "scoreboardContainer null");
}

function showScoreboardUI()
{
	$.Msg( "showScoreboardUI called");
	
	var scoreboardContainer = $("#ScoreboardContainer");
	if (scoreboardContainer) 
	{
		$.Msg( "scoreboardContainer not null");
		$.Msg( "scoreboardContainer.style.visibility = ", scoreboardContainer.style.visibility);
		scoreboardContainer.style.visibility = "visible";
	}
	else 
		$.Msg( "scoreboardContainer null");
}


//Get the current visibility of #ScoreboardContainer and flip it. Visibility Values {visible, collapse}
function toggleScoreboardVisibility()
{
	$.Msg( "JS toggleScoreboardVisibility called");
	
	var scoreboardContainer = $("#ScoreboardContainer");
	$.Msg( "JS scoreboardContainer = ", scoreboardContainer);
	if (scoreboardContainer) 
	{
		$.Msg( "JS scoreboardContainer.style.visibility = ", scoreboardContainer.style.visibility);

		if (scoreboardContainer.style.visibility == "visible")
			scoreboardContainer.style.visibility = "collapse";
		else 
			scoreboardContainer.style.visibility = "visible";
	}
	else 
	{
		$.Msg( "scoreboardContainer null");
	}
}


//Subscribe these events to these functions. 
//These functions are called/triggered from lua via: CustomGameEventManager:Send_ServerToAllClients("showScoreboardUIEvent", {})
GameEvents.Subscribe( "updateScoreboardData", updateScoreboardData);
GameEvents.Subscribe( "showScoreboardUIEvent", showScoreboardUI);
GameEvents.Subscribe( "hideScoreboardUIEvent", hideScoreboardUI);



