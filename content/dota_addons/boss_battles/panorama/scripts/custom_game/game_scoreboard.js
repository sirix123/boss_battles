

function getRandomColor() {
  var letters = '0123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function DpsMeterUpdate( table_name, key, data )
{
	//DEBUG:
	// $.Msg("DpsMeterUpdate( table_name, key, data )")
	// $.Msg("table_name = ", table_name)
	// $.Msg("key = ", key)
	// $.Msg("data = ", data)

	//TODO: make it find and then update just the dps.text instead of delete and re-drawing the UI panels.

	var dpsMeterContainer = $("#dps_meter")
	if (dpsMeterContainer)
	{
		for (i = 0; i < dpsMeterContainer.GetChildCount(); i++  )
		{
			//Skip first child, its the col header 
			if (i == 0)
				continue;
			var child = dpsMeterContainer.GetChild(i)
			child.DeleteAsync(0);
		}
		for (var row in data)
		{
			var containerPanel = $.CreatePanel("Panel", dpsMeterContainer, data);
		 	containerPanel.BLoadLayoutSnippet("dps_meter_row");

			var dpsRowContainer = containerPanel.FindChildInLayoutFile("dps_row")
			//Update text of UI Label elements
			var playerName = dpsRowContainer.FindChildInLayoutFile("dps_meter_playerName")
			var dps = dpsRowContainer.FindChildInLayoutFile("dps_meter_dps")
			playerName.text = data[row].hero
			dps.text = data[row].dps

			//Set row styling:
			//currently setting styling purely in css, but might do it later for more adv, alternate row colors etc
			//dpsRowContainer.style.backgroundColor = getRandomColor()
		}
	}
}

CustomNetTables.SubscribeNetTableListener( "dps_meter", DpsMeterUpdate );

function showDpsMeterUI()
{
	var dpsMeter = $("#dps_meter");
	if (dpsMeter)
		$.Msg("dpsMeter != null. setting visible")
		dpsMeter.style.visibility = "visible";	
}


//END DPS METER

// SHOW BOSS SCOREBOARD

function hideScoreboardUI()
{
	var bsb = $("#bsb");
	if (bsb)
		bsb.style.visibility = "collapse";
}

function showScoreboardUI(table_data)
{
	$.Msg("showScoreboardUI tableData = ", table_data)
	var bsb = $("#bsb");
	if (bsb)
		bsb.style.visibility = "visible";
	//Net tables version: not currently used. 
	//var table_data = CustomNetTables.GetAllTableValues("dmg_done");

	//Boss info section:
	var bsb_bossHeader = $("#bsb_boss_header");
	for (i = 0; i < bsb_bossHeader.GetChildCount(); i++  )
	{
		var child = bsb_bossHeader.GetChild(i)
		child.DeleteAsync(0);
	}

	var bsb_bossInfoContainer = $.CreatePanel("Panel", bsb_bossHeader, table_data);
	bsb_bossInfoContainer.BLoadLayoutSnippet("bsb_header_bossFight_info");	

	var bossName = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_name")
	var bossDuration = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_duration")
	var bossWinLose = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_winLose")

	bossName.text = table_data.bossName
	bossDuration.text = table_data.bossDuration
	bossWinLose.text = table_data.bossWinLose

	var bsbTableContainer = $("#bsb_table_rows");

	//DELETE all current rows and then re-create them
	for (i = 0; i < bsbTableContainer.GetChildCount(); i++  )
	{
		var child = bsbTableContainer.GetChild(i)
		child.DeleteAsync(0);
	}

	//Player scoreboard rows section:
	for(var row in table_data)
	{
		//rows where row is an int, are the player rows
		if (row > 0 ) 
		{
			var val = table_data[row]
			CreateBossScoreBoardRow(val, row)
		}
		else 
		{
			//skip these rows. they're the bossName, bossDuration, bossWinLose
		}

		//DEBUG 
		// $.Msg("row = ", row)
		// $.Msg("table_data[row] = ", table_data[row])
	}
}


function CreateBossScoreBoardRow(rowData, rowId)
{
	//$.Msg("CreateBossScoreBoardRow(rowData, rowId). rowId = ", rowId)
	var bsbTableContainer = $("#bsb_table_rows");
	if (bsbTableContainer) 
	{
		var containerPanel = $.CreatePanel("Panel", bsbTableContainer, rowData);
		containerPanel.BLoadLayoutSnippet("bsb_table_row");

		//class_image
		var classImage = containerPanel.FindChildInLayoutFile("bsb_table_row_class")
			classImage.SetImage(rowData.class_icon);

		var playerName = containerPanel.FindChildInLayoutFile("bsb_table_row_player")
		if (!!playerName) //if not null, set text
			playerName.text = rowData.player_name

		var dmgDone = containerPanel.FindChildInLayoutFile("bsb_table_row_dmgDone")
		if (!!dmgDone) //if not null, set text
			dmgDone.text = rowData.dmg_done

		var dpsDone = containerPanel.FindChildInLayoutFile("bsb_table_row_dpsDone")
		if (!!dpsDone) //if not null, set text
			dpsDone.text = rowData.dps

		var dmgTaken = containerPanel.FindChildInLayoutFile("bsb_table_row_dmgTaken")
		if (!!dmgTaken)
			dmgTaken.text = rowData.dmg_taken
	} //end if (bsbTableContainer) 
	else {
		$.Msg("bsbTableContainer/ #bsb_table_rows null. ")	
	}
}

// END SHOW BOSS SCOREBOARD

//Subscribe these events to these functions. 
//These functions are called/triggered from lua via: CustomGameEventManager:Send_ServerToAllClients("showScoreboardUIEvent", {})
GameEvents.Subscribe( "showScoreboardUIEvent", showScoreboardUI);
GameEvents.Subscribe( "hideScoreboardUIEvent", hideScoreboardUI);
GameEvents.Subscribe( "showDpsMeterUIEvent", showDpsMeterUI);
