qop_passive = class({})

LinkLuaModifier("qop_passive_modifier", "player/queenofpain/qop_passive", LUA_MODIFIER_MOTION_NONE)

function qop_passive:GetIntrinsicModifierName()
	return "qop_passive_modifier"
end

qop_passive_modifier = class({})

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

function qop_passive_modifier:IsHidden() return true end

function qop_passive_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function qop_passive_modifier:OnTakeDamage( params )
    if IsServer() then
        --print("params.attacker.name ",params.attacker:GetUnitName())
        if params.attacker:GetUnitName() == "npc_dota_hero_queenofpain" then
            --print("healing")
            --print("original_damage ",params.original_damage)
            --print("damage ",params.damage)

            local damage = params.original_damage
            local heal_value = damage * ( self:GetAbility():GetSpecialValueFor( "dmg_to_heal_reduction" ) / 100)

            local friendlies = FindUnitsInRadius(
                self:GetParent():GetTeamNumber(),	-- int, your team number
                self:GetParent():GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            for _, friend in pairs(friendlies) do
                if friend:HasModifier("ally_buff_heal") then
                    friend:Heal(heal_value, self:GetParent())

                    -- particle effect
                    local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
                    self.explode_particle = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, friend)
                    ParticleManager:SetParticleControl( self.explode_particle, 0, friend:GetAbsOrigin() )
                    ParticleManager:ReleaseParticleIndex(self.explode_particle)
                end
            end
        end
    end
end
