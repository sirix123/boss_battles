function HideOther(top_panel){
    var tp_scroll = top_panel.FindChildTraverse("inventory_tpscroll_container");
    tp_scroll.style.visibility = "collapse";

    var neutral_item = top_panel.FindChildTraverse("inventory_neutral_slot_container");
    neutral_item.style.visibility = "collapse";

    var talents = top_panel.FindChildTraverse("StatBranch");
    talents.style.visibility = "collapse";

    var guides = top_panel.FindChildTraverse("GuideFlyout");
    guides.style.visibility = "collapse";
}

function HideDefaults(){
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false);
    //GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);
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
    var abilityPanel = top_panel.FindChildTraverse(abilityName);
    var hotkey = abilityPanel.FindChildTraverse("HotkeyText");

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

(function() {
    var top_panel = $.GetContextPanel();
    while(top_panel.GetParent() != null){
        top_panel = top_panel.GetParent();
    }

    ModifyHotkeyBoxes(top_panel);
    HideDefaults();
    HideOther(top_panel);

})();
