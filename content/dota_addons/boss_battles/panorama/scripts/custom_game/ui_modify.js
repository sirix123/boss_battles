GameEvents.Subscribe( "picking_done", Init );
GameEvents.Subscribe( "player_reconnect", Init );

function HideOther(top_panel){
    var tp_scroll = top_panel.FindChildTraverse("inventory_tpscroll_container");
    tp_scroll.style.visibility = "collapse";

    var neutral_item = top_panel.FindChildTraverse("inventory_neutral_slot_container");
    neutral_item.style.visibility = "collapse";

    var talents = top_panel.FindChildTraverse("StatBranchBG");
    talents.style.visibility = "collapse";

    var talents_2 = top_panel.FindChildTraverse("StatBranchGraphics");
    talents_2.style.visibility = "collapse";

    var talents_3 = top_panel.FindChildTraverse("StatBranch");
    talents_3.style.visibility = "collapse";

    var guides = top_panel.FindChildTraverse("GuideFlyout");
    guides.style.visibility = "collapse";

    var aghs = top_panel.FindChildTraverse("AghsStatusContainer");
    aghs.style.visibility = "collapse";

    var aghs_shards = top_panel.FindChildTraverse("AghsStatusShard");
    aghs_shards.style.visibility = "collapse";

    var aghs_effects = top_panel.FindChildTraverse("AghsAquireEffects");
    aghs_effects.style.visibility = "collapse";

    var damage = top_panel.FindChildTraverse("Damage");
    damage.style.visibility = "collapse";

    var stragiint = top_panel.FindChildTraverse("stragiint");
    stragiint.style.visibility = "collapse";

    var shop = top_panel.FindChildTraverse("shop_launcher_bg");
    shop.style.visibility = "collapse";

    var shop_button = top_panel.FindChildTraverse("ShopButton");
    shop_button.style.visibility = "collapse";

    var kill_cam = top_panel.FindChildTraverse("KillCam");
    kill_cam.style.visibility = "collapse";

    var LevelUpGlow = top_panel.FindChildTraverse("LevelUpGlow");
    LevelUpGlow.style.visibility = "collapse";

    var statBranchdiaglog = top_panel.FindChildTraverse("statbranchdialog");
    if ( statBranchdiaglog !== undefined ){
        statBranchdiaglog.style.visibility = "collapse";
    }

    let hero_name = ""
    let playerId = Players.GetLocalPlayer()
    let player_hero = Players.GetPlayerSelectedHero( playerId )
    if ( player_hero == "npc_dota_hero_crystal_maiden" 	) 	    { hero_name = "RYLAI"; }
	if ( player_hero == "npc_dota_hero_phantom_assassin" 	) 	{ hero_name = "NIGHTBLADE"; }
	if ( player_hero == "npc_dota_hero_juggernaut" 		) 	    { hero_name = "BLADEMASTER"; }
	if ( player_hero == "npc_dota_hero_windrunner" 		) 	    { hero_name = "WINDRUNNER"; }
	if ( player_hero == "npc_dota_hero_lina" 				) 	{ hero_name = "LINA"; }
	if ( player_hero == "npc_dota_hero_omniknight" 		) 	    { hero_name = "NOCENS"; }
	if ( player_hero == "npc_dota_hero_grimstroke" 		) 	    { hero_name = "ZEEKE"; }
	if ( player_hero == "npc_dota_hero_queenofpain" 		) 	{ hero_name = "AKASHA"; }
	if ( player_hero == "npc_dota_hero_hoodwink" 			) 	{ hero_name = "RAT"; }
	if ( player_hero == "npc_dota_hero_huskar" 			) 	    { hero_name = "TEMPLAR"; }
    if ( player_hero == "npc_dota_hero_pugna" 			) 	    { hero_name = "PUGNA"; }
    if ( player_hero == "npc_dota_hero_oracle" 			) 	    { hero_name = "NERIF"; }

    var dotaHudUnitName = top_panel.FindChildTraverse('UnitNameLabel');
    dotaHudUnitName.text = hero_name


}

function HideDefaults(){
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false); 
    
}


function ModifyHotkeyBox(top_panel) {
    if(!ModifyHotkeyText(top_panel, "Ability0", "Q")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability1", "W")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability2", "E")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability3", "R")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability4", "T")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability5", "Space")){ return false; }
    return true;
}

function ModifyHotkeyText(top_panel, abilityName, text){
    
    if(top_panel){
        let abilityPanel = top_panel.FindChildTraverse(abilityName);

        if (abilityPanel){
            let hotkey = abilityPanel.FindChildTraverse("HotkeyText");

            if(hotkey){
                hotkey.text = text;
                hotkey.GetParent().visible = true;
        
                return true;
            } 
        }
    }
    return false;
}

function ModifyHotkeyBoxes(top_panel){
    (function tic()
    {
        if(!ModifyHotkeyBox(top_panel)){
            $.Schedule(2.0, tic);
        }
    })();
}


function Init(){
    var top_panel = $.GetContextPanel();
    while(top_panel.GetParent() != null)
    {
        top_panel = top_panel.GetParent();
    }

    // ModifyHotkeyBoxes(top_panel);
    HideDefaults();
    HideOther(top_panel);
}

