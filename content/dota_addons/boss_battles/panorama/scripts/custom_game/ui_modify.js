GameEvents.Subscribe( "picking_done", Init );

function HideOther(top_panel){
    var tp_scroll = top_panel.FindChildTraverse("inventory_tpscroll_container");
    tp_scroll.style.visibility = "collapse";

    var neutral_item = top_panel.FindChildTraverse("inventory_neutral_slot_container");
    neutral_item.style.visibility = "collapse";

    var talents = top_panel.FindChildTraverse("StatBranch");
    talents.style.visibility = "collapse";

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
    if(!ModifyHotkeyText(top_panel, "Ability0", "L-Mouse")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability1", "R-Mouse")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability2", "Q")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability3", "E")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability4", "R")){ return false; }
    if(!ModifyHotkeyText(top_panel, "Ability5", "Space")){ return false; }
    return true;
}

function ModifyHotkeyText(top_panel, abilityName, text){
    
    if(top_panel){
        var abilityPanel = top_panel.FindChildTraverse(abilityName);
    }

    if (abilityPanel){
        var hotkey = abilityPanel.FindChildTraverse("HotkeyText");
    }
   
    if(hotkey){
        hotkey.text = text;
        hotkey.GetParent().visible = true;

        return true;
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

function ModifyPlayers(top_panel){

    // notes
    // removing the mana/health bar from the bottom HUD ui / changing colour should be straight forward
    // BUT if want that to match the stuff above the hero we would need to create our own custom stuff (overhead) there are a few exmaples for this so might not be too hard

    //$.Msg("modify mana bars")

    /*var manaBar_left = top_panel.FindChildTraverse("ManaProgress_Left");
    manaBar_left.RemoveClass("ProgressBarLeft");
    manaBar_left.AddClass("ProgressBarLeft_v2")

    var manaBar_right = top_panel.FindChildTraverse("ManaProgress_Right"); 
    manaBar_right.RemoveClass("ProgressBarRight");
    manaBar_right.AddClass("ProgressBarRight_v2")*/

}

/*(function() {
    var top_panel = $.GetContextPanel();
    while(top_panel.GetParent() != null){
        top_panel = top_panel.GetParent();
    }

    ModifyHotkeyBoxes(top_panel);
    HideDefaults();
    HideOther(top_panel);

})();*/

function Init(){
    var top_panel = $.GetContextPanel();
    while(top_panel.GetParent() != null)
    {
        top_panel = top_panel.GetParent();
    }

    ModifyHotkeyBoxes(top_panel);
    HideDefaults();
    HideOther(top_panel);
    //ModifyPlayers(top_panel);

}

