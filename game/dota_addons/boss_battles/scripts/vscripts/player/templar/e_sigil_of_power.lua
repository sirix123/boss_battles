e_sigil_of_power = class({})
LinkLuaModifier("e_sigil_of_power_modifier", "player/templar/modifiers/e_sigil_of_power_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_sigil_of_power_modifier_thinker", "player/templar/modifiers/e_sigil_of_power_modifier_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_sigil_of_power_modifier_buff", "player/templar/modifiers/e_sigil_of_power_modifier_buff", LUA_MODIFIER_MOTION_NONE)


function e_sigil_of_power:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_sigil_of_power:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------


function e_sigil_of_power:OnSpellStart()

    self.caster = self:GetCaster()

    local radius = self:GetSpecialValueFor( "radius" )

    local nFXIndex_1 = ParticleManager:CreateParticle( "particles/templar/templar_blink_overwhelming_burst.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( nFXIndex_1, 0, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControl( nFXIndex_1, 1, Vector(radius,radius,radius) )
    ParticleManager:ReleaseParticleIndex(nFXIndex_1)

    local stacks = 0
    if self:GetCaster():HasModifier("templar_power_charge") then
        stacks = self:GetCaster():GetModifierStackCount("templar_power_charge", self:GetCaster())
        self:GetCaster():RemoveModifierByName("templar_power_charge")
    end

    local dmage_boost_per_charge = self:GetSpecialValueFor( "damage_boost_per_power_charge_consumed" )

    local damage_boost = dmage_boost_per_charge * stacks

    local friendlies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.caster:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    if friendlies ~= nil and #friendlies ~= 0 then
        for _, friend in pairs(friendlies) do
            friend:AddNewModifier(self.caster, self, "e_sigil_of_power_modifier_buff",
            {
                duration = self:GetSpecialValueFor("duration"),
                damage_boost = damage_boost,
            })
        end
    end

    local dmg = 0
    if stacks ~= 0 and stacks ~=nil then
        dmg = self:GetSpecialValueFor("damage") * stacks
    else
        dmg = self:GetSpecialValueFor("damage")
    end

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.caster:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    if enemies ~= nil and #enemies ~= 0 then

        for _, enemy in pairs(enemies) do

            self.dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = dmg,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(self.dmgTable)

        end
    end

    local sound_cast = "Blink_Layer.Overwhelming"
    EmitSoundOn( sound_cast, self:GetCaster() )

end
---------------------------------------------------------------------------