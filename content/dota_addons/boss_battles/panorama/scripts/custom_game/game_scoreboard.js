//Expects data like: an array of 4 'row' elements, 
//Each row contains: playername, portrait, rank, dmg_done, heal_done, dmg_tkn
function setupScoreboard(data)
{	
	$.Msg( "JS updateScoreboardData: data =  " , data );	
	for (var i in data)
	{
		//data[i] contains values for one scoreboard row.
		//$.Msg( "data[i] =  ", data[i] );		
		createScoreboardRow(data[i])
		
	}
}


//Load the scoreboard snippets and setup the initial values
function createScoreboardRow(rowData)
{
	//$.Msg( "JS createScoreboardRow: rowData =  " , rowData );
	var scoreboardContainer = $("#ScoreboardContainer");
	//$.Msg( "JS scoreboardContainer = ", scoreboardContainer);
	if (scoreboardContainer) 
	{
		var containerPanel = $.CreatePanel("Panel", scoreboardContainer, rowData);
		containerPanel.BLoadLayoutSnippet("GameScoreboardRowTopSnippet");

		var playerNameLabelElement = containerPanel.FindChildInLayoutFile("PlayerNameLabel")
		if (!!playerNameLabelElement) //if not null, set text
			playerNameLabelElement.text = rowData.playerName

		containerPanel.BLoadLayoutSnippet("ScoreboardRowBotSnippet");

		var dmgDoneLabelElement = containerPanel.FindChildInLayoutFile("DmgDoneLabel")
		if (!!dmgDoneLabelElement) //if not null, set text
			dmgDoneLabelElement.text = rowData.dmgDone


		var healDoneLabelElement = containerPanel.FindChildInLayoutFile("HealDoneLabel")
		if (!!healDoneLabelElement) //if not null, set text
			healDoneLabelElement.text = rowData.healDone								

		var dmgTknLabelElement = containerPanel.FindChildInLayoutFile("DmgTknLabel")
		if (!!dmgTknLabelElement) //if not null, set text
			dmgTknLabelElement.text = rowData.dmgTkn				


		var portraitImageElement = containerPanel.FindChildInLayoutFile("PortailImage")


		$.Msg( "portraitImageElement = ", portraitImageElement);
		
		if (!!portraitImageElement) //if not null, set text
		{
			$.Msg( "setting portraitImageElement image = ", rowData.portrait);
			//portraitLabelElement.text = rowData.portrait
			portraitImageElement.SetImage(rowData.portrait);
		}

		var rankImageElement = containerPanel.FindChildInLayoutFile("RankImage")
		$.Msg( "JS rankImageElement = ", rankImageElement);
		if (!!rankImageElement) //if not null, set text
		{			
			$.Msg( "setting rankImageElement image = ", rowData.rank);
			rankImageElement.SetImage(rowData.rank);
		}
	}	
	else 
		$.Msg( "scoreboardContainer is null. Returning");	
}


//Update the scoreboard snippet?





function hideScoreboardUI()
{
	$.Msg( "hideScoreboardUI called");
	
	var scoreboardContainer = $("#ScoreboardContainer");
	if (scoreboardContainer) 
	{
		$.Msg( "scoreboardContainer current visibility = ", scoreboardContainer.style.visibility);
		scoreboardContainer.style.visibility = "collapse";
		$.Msg( "scoreboardContainer new visibility = ", scoreboardContainer.style.visibility);
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
		$.Msg( "scoreboardContainer current visibility = ", scoreboardContainer.style.visibility);
		scoreboardContainer.style.visibility = "visible";
		$.Msg( "scoreboardContainer new visibility = ", scoreboardContainer.style.visibility);
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
GameEvents.Subscribe( "setupScoreboard", setupScoreboard);
GameEvents.Subscribe( "showScoreboardUIEvent", showScoreboardUI);
GameEvents.Subscribe( "hideScoreboardUIEvent", hideScoreboardUI);



