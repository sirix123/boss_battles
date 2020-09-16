///////////////////////////////
//SUBSCRIBE TO NET TABLE IN JS EXAMPLE:

// SubscribeToNetTableKey("main", "targetingIndicators", true, function(data){
//     targetingIndicators = data;
// });


//CODE FROM LUA THAT CALLS THIS:

// function TargetingIndicator:Load()
//     local abilities_kv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
//     local targetingIndicators = {}

//     for key, ability in pairs(abilities_kv) do
//         if ability.TargetingIndicator then
//             targetingIndicators[key] = ability.TargetingIndicator
//         end
//     end

//     CustomNetTables:SetTableValue("main", "targetingIndicators", targetingIndicators)
// end

// CustomNetTables.SubscribeNetTableListener("dmg_done", DmgDoneTableChange);

// function DmgDoneTableChange(table_name, key, data){
// 	$.Msg( "1. JS DmgDoneTableChange " );

// 	$.Msg( "DmgDoneTableChange table_name = ", table_name );
// 	$.Msg( "DmgDoneTableChange key = ", key );
// 	$.Msg( "DmgDoneTableChange data = ", data );
// }


function hideScoreboardUI()
{
	//$.Msg( "hideScoreboardUI called");
	var bsb = $("#bsb");
	if (bsb)
		bsb.style.visibility = "collapse";
	else 
		$.Msg( "bsb null");
}

function showScoreboardUI(table_data)
{
	//$.Msg( "showScoreboardUI called");
	//Net tables version: not currently used. 
	//var table_data = CustomNetTables.GetAllTableValues("dmg_done");


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

	bossName.text = "Beastmaster"
	bossDuration.text = "1:47"
	bossWinLose.text = "Defeat!"


	var bsb = $("#bsb");
	if (bsb)
	{
		bsb.style.visibility = "visible";
	}
	else 
		$.Msg( "bsb null");

	
	//$.Msg( "table_data = ", table_data);	
	for(var row in table_data)
	{
		var key = row
		var val = table_data[row]

		//DEBUG:
		// var player_name = val.player_name
		// var class_name = val.class_name
		// var class_icon = val.class_icon
		// var dmg_done = val.dmg_done
		// var dmg_taken = val.dmg_taken
		// $.Msg( "key = ", key);			
		// $.Msg( "val = ", val);			
		// $.Msg( "player_name = ", player_name);
		// $.Msg( "class_name = ", class_name);
		// $.Msg( "class_icon = ", class_icon);
		// $.Msg( "dmg_done = ", dmg_done);
		// $.Msg( "dmg_taken = ", dmg_taken);

		CreateBossScoreBoardRow(val)
	}
	
}


function CreateBossScoreBoardRow(rowData)
{
	//$.Msg( "CreateBossScoreBoardRow called. rowData  = ", rowData );	
	var bsbTableContainer = $("#bsb_table_rows");

	//TODO: figure out how to get children and update their values instead of deleting and re-creating
	//DELETE all current rows and then re-create them
	for (i = 0; i < bsbTableContainer.GetChildCount(); i++  )
	{
		var child = bsbTableContainer.GetChild(i)
		child.DeleteAsync(0);
	}

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

		var dmgTaken = containerPanel.FindChildInLayoutFile("bsb_table_row_dmgTaken")
		if (!!dmgTaken)
			dmgTaken.text = rowData.dmg_taken
	} //end if (bsbTableContainer) 
	else {
		$.Msg("bsbTableContainer/ #bsb_table_rows null. ")	
	}

		
}

//Subscribe these events to these functions. 
//These functions are called/triggered from lua via: CustomGameEventManager:Send_ServerToAllClients("showScoreboardUIEvent", {})
GameEvents.Subscribe( "showScoreboardUIEvent", showScoreboardUI);
GameEvents.Subscribe( "hideScoreboardUIEvent", hideScoreboardUI);