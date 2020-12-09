bird_death_modifier = class({})

LinkLuaModifier("beastmaster_bloodlust_modifier", "bosses/beastmaster/beastmaster_bloodlust_modifier", LUA_MODIFIER_MOTION_NONE)
-----------------------------------------------------------------------------

function bird_death_modifier:RemoveOnDeath()
    return true
end

function bird_death_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function bird_death_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function bird_death_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end


function bird_death_modifier:OnDestroy()
    if not IsServer() then return nil end

    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_ALL,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do

        -- grabbed player debuff, release him, remove modifier
        if unit:HasModifier("grab_player_modifier") == true then
            unit:RemoveModifierByName("grab_player_modifier")
        end

        -- if player has a mark remove it
        if unit:HasModifier("beastmaster_mark_modifier") == true then
            unit:RemoveModifierByName("beastmaster_mark_modifier")
        end

        if unit:GetUnitName() == "npc_beastmaster" then
            -- adds modifier to bear that increases as and ms
            unit:AddNewModifier( self:GetCaster(), self, "beastmaster_bloodlust_modifier", { duration = 15 } )

            local nFXIndex = ParticleManager:CreateParticle( "particles/beastmaster/bear_lust_ogre_magi_bloodlust_buff.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )
            ParticleManager:ReleaseParticleIndex( nFXIndex )

            -- start cast bird cooldown
            unit:GetAbilityByIndex(5):StartCooldown( 20 )

            -- end cd for mark
            unit:GetAbilityByIndex(0):EndCooldown()

            -- voiceline for beastmasters
            EmitGlobalSound("beastmaster_beas_death_14")

            local nfx = ParticleManager:CreateParticle("particles/beastmaster/beastmaster_razor_static_link.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_static", self:GetParent():GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(nfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)

        end
    end
end

