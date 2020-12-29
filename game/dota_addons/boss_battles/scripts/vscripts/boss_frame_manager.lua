if boss_frame_manager == nil then
    boss_frame_manager = class({})
end

-- this will hide/show the boss hp frame
function boss_frame_manager:ShowBossHpFrame( sBoss, hBoss )


end

function boss_frame_manager:HideBossHpFrame()
    CustomGameEventManager:Send_ServerToAllClients( "hide_boss_health_frame", { } )
end
--------------------------------------------------

-- this will hide the boss mana frame
function boss_frame_manager:ShowBossManaFrame()


end

function boss_frame_manager:HideBossManaFrame()
    CustomGameEventManager:Send_ServerToAllClients( "hide_boss_mana_frame", { } )
end
--------------------------------------------------

-- show/hide all frames (mostly used for debugging, shouldn,t use this in an actual prod fight)
function boss_frame_manager:HideBossFrames()
    self.hideFrames = true

    CustomNetTables:SetTableValue("boss_frame", "hide", {})
end

function boss_frame_manager:ShowBossFrames( boss )
    self.hideFrames = false

    local hp = boss:GetHealth()
    local maxHp = boss:GetMaxHealth()
    local hpPercent = boss:GetHealthPercent()
    local mpPercent = boss:GetManaPercent()

    local bossFrameData = {}
    bossFrameData.hp = boss:GetHealth()
    bossFrameData.maxHp = boss:GetMaxHealth()
    bossFrameData.hpPercent = boss:GetHealthPercent()
    bossFrameData.mp = boss:GetMana()
    bossFrameData.maxMp = boss:GetMaxMana()
    bossFrameData.mpPercent = boss:GetManaPercent()

    CustomNetTables:SetTableValue("boss_frame", "key", bossFrameData)

end
-------------------------------------------------

-- Update/stop updating boss frame hp and mana
-- this will also show the frames (hp and mana)
function boss_frame_manager:UpdateManaHealthFrame( boss )

    -- set the boss name once


    Timers:CreateTimer(function()
        if boss ~= nil then

            if boss:GetHealthPercent() == 0 or self.hideFrames == true then
                CustomNetTables:SetTableValue("boss_frame", "hide", {})
                return false
            end

            local hp = boss:GetHealth()
            local maxHp = boss:GetMaxHealth()
            local hpPercent = boss:GetHealthPercent()
            local mpPercent = boss:GetManaPercent()

            local bossFrameData = {}
            bossFrameData.hp = boss:GetHealth()
            bossFrameData.maxHp = boss:GetMaxHealth()
            bossFrameData.hpPercent = boss:GetHealthPercent()
            bossFrameData.mp = boss:GetMana()
            bossFrameData.maxMp = boss:GetMaxMana()
            bossFrameData.mpPercent = boss:GetManaPercent()

            CustomNetTables:SetTableValue("boss_frame", "key", bossFrameData)

        else

            CustomNetTables:SetTableValue("boss_frame", "hide", {})

        end

        return 1;

    end)
end