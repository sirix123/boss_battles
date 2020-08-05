electric_turret_electric_charge_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function electric_turret_electric_charge_modifier:IsHidden()
	return false
end

function electric_turret_electric_charge_modifier:IsDebuff()
	return true
end
-----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:GetEffectName()
	return "particles/clock/base_buff_spreading_ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function electric_turret_electric_charge_modifier:GetStatusEffectName()
	return "particles/clock/base_buff_spreading_ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end
-----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.stopTimer = false
        self.radius = kv.radius

        -- player getting buff from electric turret has no duration, once it jumps to a player it has a duration and every jump reduces duration by some amount
        self.duration = 10

        -- i want some indicator so players can see the jump range 
        if self.parent:GetUnitName() ~= "npc_clock" and self.parent:GetUnitName() ~= "npc_flame_turret" and self.parent:GetUnitName() ~= "npc_assistant" and self.parent:GetUnitName() ~= "npc_chain_gun_turret" and self.parent:GetUnitName() ~= "furnace_droid" and self.parent:GetUnitName() ~= "electric_turret" then
            -- need something to show range indiactor on caster for jump
        end

        self:StartTimer()

    end
end
----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:StartTimer()
    if IsServer() then

        -- every 2 seconds it searches for a target to jump
        Timers:CreateTimer(2, function()
            if self.stopTimer == true then
                return false
            end

            local units = FindUnitsInRadius(
                self.parent:GetTeamNumber(),	-- int, your team number
                self.parent:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                FIND_CLOSEST,	-- int, order filter
                false	-- bool, can grow cache
            )

            --npc_clock, npc_flame_turret, npc_assistant, npc_chain_gun_turret, furnace_droid, electric_turret
            if units ~= nil and #units ~= 0 then
                for _, unit in pairs(units) do

                    -- check if unit name is the parents so if it finds itself it doesnt remove the modifier
                    if unit:GetUnitName() ~= self.parent:GetUnitName() then

                        -- if furnace droid in range of clock killself and give clock mana
                        if unit:GetUnitName() == "npc_clock" then
                            -- if buff is on clock apply this other modifier with x duration.... (givemana (flat amount))
                            unit:GiveMana(20)

                            -- blow droid up
                            if self.parent:GetUnitName() == "furnace_droid" then
                                self.parent:ForceKill(false)
                            end

                        -- if electric turret finds a furance droid give the charge modifier
                        elseif unit:GetUnitName() == "furnace_droid" and self.parent:GetUnitName() == "electric_turret" then
                            unit:AddNewModifier(self.parent, self, "electric_turret_electric_charge_modifier", { duration = -1, radius = self.radius, })


                        -- if clock minions in range of this modifier give them their specific dmg minion modifier with the same particle effect as this modifier
                        elseif unit:GetUnitName() == "npc_chain_gun_turret" or unit:GetUnitName() == "npc_flame_turret" or unit:GetUnitName() == "npc_assistant" or unit:GetUnitName() == "furnace_droid" then
                            -- if buff is on clock minions give a modifier permanent until death (movespeed and attack rate for turrets)
                            unit:AddNewModifier(self.parent, self, "electric_turret_minion_buff", { duration = -1 })

                        -- if not clock or minion (so a player) destroy buff on self and apply to friendly
                        elseif
                        unit:GetUnitName() ~= "npc_clock" and
                        unit:GetUnitName() ~= "npc_flame_turret" and
                        unit:GetUnitName() ~= "npc_assistant" and
                        unit:GetUnitName() ~= "npc_chain_gun_turret" and
                        unit:GetUnitName() ~= "furnace_droid" and
                        unit:GetUnitName() ~= "electric_turret" and
                        self.parent:GetUnitName() ~= "npc_clock" and
                        self.parent:GetUnitName() ~= "npc_flame_turret" and
                        self.parent:GetUnitName() ~= "npc_assistant" and
                        self.parent:GetUnitName() ~= "npc_chain_gun_turret" and
                        self.parent:GetUnitName() ~= "furnace_droid"
                        then

                            if self.parent:GetUnitName() == "electric_turret" then
                                self.parent:ForceKill(false)
                            end

                            -- jump modifier to another player (how to delete buff from parent if it jumps?)
                            unit:AddNewModifier(self.parent, self, "electric_turret_electric_charge_modifier", { duration = self.duration, radius = self.radius, })

                            -- if buff is on players give lingering dmg buff
                            unit:AddNewModifier(self.parent, self, "electric_turret_player_buff", { duration = self.duration })

                            -- remove charge from parent once it jumps t another player (how long do we wait before we run this? buff duration?)
                            Timers:CreateTimer(self.duration, function()
                                unit:RemoveModifierByName("electric_turret_electric_charge_modifier")
                                return false
                            end)
                        end
                    end
                end
            end

            return 2
        end)

    end
end
----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:OnDestroy()
    if IsServer() then
        self.stopTimer = true
    end
end
----------------------------------------------------------------------------
--[[
function electric_turret_electric_charge_modifier:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:GetModifierConstantManaRegen ( params )
	return 10
end
--------------------------------------------------------------------------------

function electric_turret_electric_charge_modifier:GetModifierPercentageCooldown( params )
	return 50
end]]
--------------------------------------------------------------------------------
