

function getRandomColor() {
  var letters = '0123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function formatIntMMSS(num) {
    var minutes = Math.floor((num) / 60);
    var seconds = num - (minutes * 60);

    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    return minutes + ':' + seconds;
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
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
	var bsb = $("#bsb_parent");
	if (bsb)
		bsb.style.visibility = "collapse";
}

function showScoreboardUI( table_data )
{
	//$.Msg("mode = ", mode)

	var bsb = $("#bsb_parent");
	if (bsb)
		bsb.style.visibility = "visible";

	//Boss info section:
	var bsb_bossHeader = $("#bsb_boss_header");
	for (i = 0; i < bsb_bossHeader.GetChildCount(); i++  )
	{
		var child = bsb_bossHeader.GetChild(i)
		child.DeleteAsync(0);
	}

	var bsb_mode_panel = bsb.FindChildInLayoutFile("bsb_boss_mode_text")
	if (mode == "storyMode"){
		bsb_mode_panel.text = "Story Mode"
	}else if (mode == "normalMode") {
		bsb_mode_panel.text = "Normal Mode"
	}
	
	var bsb_bossInfoContainer = $.CreatePanel("Panel", bsb_bossHeader, table_data);
	bsb_bossInfoContainer.BLoadLayoutSnippet("bsb_header_bossFight_info");	

	var bossName = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_name")
	var bossDuration = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_duration")
	var bossAttemptNumber = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_attempt")

	// handler for if boss was killed or not, adds colour to the frame to show if it was killed or not
	var bossNameContainer = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_name_container")
	var bossDurationContainer = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_duration_container")
	var bossAttemptContainer = bsb_bossInfoContainer.FindChildInLayoutFile("bsb_header_boss_attempt_container")

	if ( table_data.boss_data.bossKilled == 1 ){
		bossNameContainer.AddClass("victory")
		bossDurationContainer.AddClass("victory")
		bossAttemptContainer.AddClass("victory")
	}
	else{
		bossNameContainer.AddClass("defeat")
		bossDurationContainer.AddClass("defeat")
		bossAttemptContainer.AddClass("defeat")
	}

	// close button handler
	let closeButton = bsb.FindChildInLayoutFile("bsb_header_close_button") // close button
	closeButton.SetPanelEvent( 'onactivate', function () {
		$.Msg("closeButton-activate")
		hideScoreboardUI()
	});

	bossName.text = table_data.boss_data.bossName

	// format the duration into a nice 99min:99sec format
	var data_duration = Math.round(table_data.boss_data.duration)
	bossDuration.text = formatIntMMSS(data_duration)

	bossAttemptNumber.text = table_data.boss_data.attemptNumber

	var bsbTableContainer = $("#bsb_table_rows");

	//DELETE all current rows and then re-create them
	for (i = 0; i < bsbTableContainer.GetChildCount(); i++  )
	{
		var child = bsbTableContainer.GetChild(i)
		child.DeleteAsync(0);
	}

	//Player scoreboard rows section:
	for(let i in table_data.player_data)
	{
		CreateBossScoreBoardRow(table_data.player_data[i], i)
	}

	/*Player scoreboard rows section:
	for(var row in table_data)
	{
		//rows where row is an int, are the player rows
		if (row > 0 ) 
		{
			var val = table_data.playerTable[row]
			CreateBossScoreBoardRow(table_data.playerTable[row], row)
		}
		else 
		{
			//skip these rows. they're the bossName, bossDuration, bossWinLose
		}

		//DEBUG 
		// $.Msg("row = ", row)
		// $.Msg("table_data[row] = ", table_data[row])
	}*/
}


function CreateBossScoreBoardRow(rowData, rowId)
{
	//$.Msg("CreateBossScoreBoardRow(rowData, rowId). rowId = ", rowId)
	//$.Msg("CreateBossScoreBoardRow(rowData, rowId). rowData = ", rowData)
	var bsbTableContainer = $("#bsb_table_rows");
	if (bsbTableContainer) 
	{
		var containerPanel = $.CreatePanel("Panel", bsbTableContainer, rowData);
		containerPanel.BLoadLayoutSnippet("bsb_table_row");

		var heroImage = containerPanel.FindChildInLayoutFile("HeroImage")
		heroImage.heroname = rowData.heroName;

		var playerName = containerPanel.FindChildInLayoutFile("bsb_table_row_player")
		if (!!playerName) //if not null, set text
			playerName.text = rowData.playerName

		var dmgDone = containerPanel.FindChildInLayoutFile("bsb_table_row_dmgDone")
		if (!!dmgDone) //if not null, set text
			dmgDone.text = numberWithCommas(rowData.dmgDoneAttempt)

		var lives = containerPanel.FindChildInLayoutFile("bsb_table_row_livesRemaining")
		if (!!lives)
			lives.text = rowData.playerLives
	} //end if (bsbTableContainer) 
	else {
		$.Msg("bsbTableContainer/ #bsb_table_rows null. ")	
	}
}

// END SHOW BOSS SCOREBOARD

// grab the mode from the server
let mode = "storyMode"
function ModeChosen(event)
{
	mode = event.mode
	//$.Msg("mode = ",mode)
}

//Subscribe these events to these functions. 
//These functions are called/triggered from lua via: CustomGameEventManager:Send_ServerToAllClients("showScoreboardUIEvent", {})
GameEvents.Subscribe( "display_scoreboard", showScoreboardUI);
GameEvents.Subscribe( "hideScoreboardUIEvent", hideScoreboardUI);
GameEvents.Subscribe( "showDpsMeterUIEvent", showDpsMeterUI);
GameEvents.Subscribe( "mode_chosen", ModeChosen);
