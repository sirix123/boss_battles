m2_sword_slam = class({})
LinkLuaModifier( "m2_sword_slam_debuff", "player/warlord/modifiers/m2_sword_slam_debuff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function m2_sword_slam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 1.0)

        self.mana = self:GetCaster():GetMana()

        --- particle effect on cast
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_sword", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "blade_attachment", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(nfx)

        -- emit sound
        EmitSoundOn( "Hero_MonkeyKing.Strike.Cast", self:GetCaster() )

        return true
    end
end
---------------------------------------------------------------------------

function m2_sword_slam:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------
function m2_sword_slam:OnSpellStart()
	self.caster = self:GetCaster()
	local origin = self.caster:GetOrigin()

    local vTargetPos = nil
    vTargetPos = Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z)
    local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

    -- Find all enemy units
    local vEndPos = origin + self.caster:GetForwardVector() * self:GetCastRange(Vector(0,0,0), nil)
    local width = self:GetSpecialValueFor("width")
    local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local flags = DOTA_UNIT_TARGET_FLAG_NONE
    local units = FindUnitsInLine(self.caster:GetTeam(), origin, vEndPos, self.caster, width, teams, types, flags)

    -- dmg formula
    local dmg = self:GetSpecialValueFor( "base_dmg" )
    local dmgPerManaPoint = self:GetSpecialValueFor( "dmg_per_mana_point" )
    local dmgPerDebuffStack = self:GetSpecialValueFor( "dmg_per_debuff_stack" )
    local damage = dmg

    -- stack duration
    local duration = self:GetSpecialValueFor( "stack_duration" )

    if self:GetCaster():HasModifier("m2_sword_slam_debuff") then
        local hBuff = self:GetCaster():FindModifierByNameAndCaster("m2_sword_slam_debuff", self.caster)
        local nStackCount = hBuff:GetStackCount()
        damage = damage + ( nStackCount * dmgPerDebuffStack )
    end

    -- add mana
    damage = damage + ( self.mana * dmgPerManaPoint )

    if units ~= nil and #units ~= 0 then
        for _,unit in pairs(units) do

            local dmgTable = {
                victim = unit,
                attacker = self.caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)

            if self.caster.arcana_equipped == true and units ~= 0 then
                local nfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_crit_tgt.vpcf", PATTACH_ABSORIGIN, unit)
                ParticleManager:SetParticleControl(nfx, 1, unit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(nfx)
            end

        end
    end

    if units ~= nil and #units ~= 0 then
        self:GetCaster():AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "m2_sword_slam_debuff", -- modifier name
            {duration = duration} -- kv
        )
    end

    -- slam effect

    local particle = nil
    if self.caster.arcana_equipped == true then
        particle = "particles/warlord/juggmk_ti7_immortal_strike.vpcf"
    else
        particle = "particles/warlord/sword_slam_monkey_king_strike.vpcf"
    end

    local nfx = ParticleManager:CreateParticle(particle, PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControlForward(nfx, 0, projectile_direction)
    ParticleManager:SetParticleControl(nfx, 1, vEndPos)
    ParticleManager:ReleaseParticleIndex(nfx)

    -- slam sound
    EmitSoundOn( "Hero_MonkeyKing.Strike.Impact", self:GetCaster() )

end
--------------------------------------------------------------------------------
