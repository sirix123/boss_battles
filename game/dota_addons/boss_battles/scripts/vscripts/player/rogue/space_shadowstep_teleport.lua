space_shadowstep_teleport = class({})
LinkLuaModifier("space_shadowstep_caster_modifier", "player/rogue/modifiers/space_shadowstep_caster_modifier", LUA_MODIFIER_MOTION_NONE)

function space_shadowstep_teleport:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        -- add modifier to unit
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_shadowstep_caster_modifier", -- modifier name
            {
                duration = 10,
            }
        )

        local shadows = FindUnitsInRadius(
            caster:GetTeamNumber(),	-- int, your team number
            caster:GetOrigin(),	-- point, center point
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
                    self.vShadowOrigin = shadow:GetAbsOrigin()
                    FindClearSpaceForUnit(caster, self.vShadowOrigin , true)
                    shadow:ForceKill(false)
                end
            end
        end

        -- create unit in location teleporting from and apply the modifier
        local unit = CreateUnitByName("npc_shadow", origin, true, caster, caster, caster:GetTeamNumber())
        unit:SetOwner(caster)
        unit:EmitSound("Hero_EmberSpirit.FireRemnant.Activate")
        unit:SetRenderColor(255, 255, 255)

        -- add modifier to unit
        unit:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_shadowstep_unit_modifier", -- modifier name
            { } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

        -- swap to next ability
        caster:SwapAbilities("space_shadowstep_teleport", "space_shadowstep_teleport_back", false, true)

        -- start return cd so if player is spamming it they dont tp back straight away
        --StartCooldown
        local hAbility = caster:FindAbilityByName("space_shadowstep_teleport_back")
        hAbility:StartCooldown(hAbility:GetCooldown(1))

    end
end