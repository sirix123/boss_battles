space_shadowstep_caster_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function space_shadowstep_caster_modifier:IsHidden()
	return false
end

function space_shadowstep_caster_modifier:IsDebuff()
	return false
end

function space_shadowstep_caster_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function space_shadowstep_caster_modifier:OnCreated( kv )
    if IsServer() then
        -- references
        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

    end
end

function space_shadowstep_caster_modifier:OnRefresh( kv )
	if IsServer() then

    end
end

function space_shadowstep_caster_modifier:OnRemoved()
end

function space_shadowstep_caster_modifier:OnDestroy()
    if IsServer() then

        local shadows = FindUnitsInRadius(
            self.caster:GetTeamNumber(),	-- int, your team number
            self.caster:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if shadows ~= nil or shadows ~= 0 then
            for _, shadow in pairs(shadows) do
                if shadow:GetUnitName() == "npc_shadow" then
                    shadow:ForceKill(false)
                end
            end
        end

        FindClearSpaceForUnit(self.caster, self.origin , true)
    end
end

--------------------------------------------------------------------------------
--[[ Modifier Effects
function space_shadowstep_caster_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function space_shadowstep_caster_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end]]

--------------------------------------------------------------------------------
-- Graphics & Animations
function space_shadowstep_caster_modifier:GetEffectName()
	return "particles/rogue/rogue_ember_spirit_fire_remnant.vpcf"
end

function space_shadowstep_caster_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end