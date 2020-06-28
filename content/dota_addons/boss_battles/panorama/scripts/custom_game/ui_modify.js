
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

})();
