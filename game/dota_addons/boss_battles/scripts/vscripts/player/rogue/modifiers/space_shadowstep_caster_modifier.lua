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

        --[[local shadows = FindUnitsInRadius(
            self.caster:GetTeamNumber(),	-- int, your team number
            self.caster:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if shadows ~= nil or shadows ~= 0 then
            for _, shadow in pairs(shadows) do
                if shadow:GetUnitName() == "npc_shadow" then
                    shadow:Destroy()
                end
            end
        end

        FindClearSpaceForUnit(self.caster, self.origin , true)]]

        --[[ check what ability is in slot spacebar
        if self.caster:GetAbilityByIndex(5):GetAbilityName() == "space_shadowstep_teleport" then -- if dagger expires before teleporting to it then switch back to step 1
            self.caster:SwapAbilities("space_shadowstep_teleport", "space_shadowstep", false, true)
        elseif self.caster:GetAbilityByIndex(5):GetAbilityName() == "space_shadowstep_teleport_back" then -- normal use case of following daggers before modfier expires
            self.caster:SwapAbilities("space_shadowstep_teleport_back", "space_shadowstep", false, true)
        end]]

        --print(self.caster:GetAbilityByIndex(5):GetAbilityName())

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