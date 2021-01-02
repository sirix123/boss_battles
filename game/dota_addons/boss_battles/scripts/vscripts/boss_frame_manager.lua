if boss_frame_manager == nil then
    boss_frame_manager = class({})
end

-- this will hide/show the boss hp frame
function boss_frame_manager:ShowBossHpFrame( )
    CustomGameEventManager:Send_ServerToAllClients( "show_boss_hp_frame", { } )
end

function boss_frame_manager:HideBossHpFrame()
    CustomGameEventManager:Send_ServerToAllClients( "hide_boss_health_frame", { } )
end
--------------------------------------------------

-- this will hide the boss mana frame
function boss_frame_manager:ShowBossManaFrame()
    CustomGameEventManager:Send_ServerToAllClients( "show_boss_mana_frame", { } )
end

function boss_frame_manager:HideBossManaFrame()
    CustomGameEventManager:Send_ServerToAllClients( "hide_boss_mana_frame", { } )
end
--------------------------------------------------

-- change boss name
function boss_frame_manager:SendBossName( sBossName )

    local boss_name = ""
    if sBossName ~= nil then
        boss_name = sBossName
    else
        boss_name = RAID_TABLES[BOSS_BATTLES_ENCOUNTER_COUNTER].name
    end

    CustomGameEventManager:Send_ServerToAllClients( "change_boss_name", { bossName = boss_name } )
end

-- Update/stop updating boss frame hp and mana
-- this will also show the frames (hp and mana)
function boss_frame_manager:UpdateManaHealthFrame( boss )
    self.hideFrames = false

    if boss ~= nil then

        Timers:CreateTimer(function()

            if self.hideFrames ~= true then

                if boss:GetHealthPercent() == 0 then
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

                return 0.01;

            else
                --print("hide the frames son")
                CustomNetTables:SetTableValue("boss_frame", "hide", {})
                return false
            end

        end)
    else
        CustomNetTables:SetTableValue("boss_frame", "hide", {})
    end
end

-- show/hide all frames
function boss_frame_manager:StopUpdatingBossFrames()
    self.hideFrames = true
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