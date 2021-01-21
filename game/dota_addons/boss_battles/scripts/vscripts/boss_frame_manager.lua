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
    --if IsValidEntity(boss) ~= false then

        Timers:CreateTimer(function()
            if IsValidEntity(boss) == false then
                print("trying to hide the frames wipe")
                self:HideBossHpFrame()
                self:HideBossManaFrame()
                CustomGameEventManager:Send_ServerToAllClients( "hide_boss_frame", { } )
                CustomNetTables:SetTableValue("boss_frame", "hide", {})
                return false
            end

            if boss:IsAlive() == false then
                print("trying to hide the frames boss dead")
                self:HideBossHpFrame()
                self:HideBossManaFrame()
                CustomGameEventManager:Send_ServerToAllClients( "hide_boss_frame", { } )
                CustomNetTables:SetTableValue("boss_frame", "hide", {})
                return false
            end

            --self:ShowBossHpFrame()
            --self:ShowBossManaFrame()

            local bossFrameData = {}
            bossFrameData.hp = boss:GetHealth()
            bossFrameData.maxHp = boss:GetMaxHealth()
            bossFrameData.hpPercent = boss:GetHealthPercent()
            bossFrameData.mp = boss:GetMana()
            bossFrameData.maxMp = boss:GetMaxMana()
            bossFrameData.mpPercent = boss:GetManaPercent()

            CustomNetTables:SetTableValue("boss_frame", "key", bossFrameData)

            return 0.01;
        end)
    --else
    --end
end