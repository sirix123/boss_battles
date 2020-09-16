bear_death_modifier = class({})
-----------------------------------------------------------------------------

function bear_death_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function bear_death_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function bear_death_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end


function bear_death_modifier:OnDestroy()
    if not IsServer() then return nil end

    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_ALL,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_beastmaster" then
            -- adds modifier to bear that increases as and ms
            unit:AddNewModifier( self:GetCaster(), self, "bear_bloodlust_modifier", { duration = -1, as_bonus = 10, ms_bonus = 10 } )
            -- add stack
            local hBuff = unit:FindModifierByName( "bear_bloodlust_modifier" )
            hBuff:IncrementStackCount()

            local nFXIndex = ParticleManager:CreateParticle( "particles/beastmaster/bear_lust_ogre_magi_bloodlust_buff.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )
            ParticleManager:ReleaseParticleIndex( nFXIndex )

            -- start cast bear cooldown
            unit:GetAbilityByIndex(1):StartCooldown(  unit:GetAbilityByIndex(1):GetCooldown(1) )

            -- voiceline for beastmasters
            EmitGlobalSound("beastmaster_beas_death_14")

            --print("why does everyhting fire this?")

        end

        if unit:HasModifier("beastmaster_mark_modifier") then
            --print("remove mark")
            unit:RemoveModifierByName("beastmaster_mark_modifier")
        end

    end

end

