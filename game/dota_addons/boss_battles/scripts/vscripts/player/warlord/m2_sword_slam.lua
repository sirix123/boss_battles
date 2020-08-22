m2_sword_slam = class({})
LinkLuaModifier( "m2_sword_slam_debuff", "player/warlord/modifiers/m2_sword_slam_debuff", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function m2_sword_slam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 1.0)

        self.mana = self:GetCaster():GetMana()

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        --- particle effect on cast
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
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

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------
function m2_sword_slam:OnSpellStart()
	self.caster = self:GetCaster()
	local origin = self.caster:GetOrigin()

	-- remove casting animation
    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

	-- function in utility_functions
	--local point = Clamp(origin, self:GetCursorPosition(), self:GetCastRange(Vector(0,0,0), nil), self:GetCastRange(Vector(0,0,0), nil))

    local vTargetPos = nil
    vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
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
    local damage = dmg + ( self.mana * dmgPerManaPoint )

    -- stack duration
    local duration = self:GetSpecialValueFor( "dps_stance_m2_stack_duration" )

    for _,unit in pairs(units) do

        if self.caster:HasModifier("q_warlord_dps_stance_modifier") then
            unit:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "m2_sword_slam_debuff", -- modifier name
                {duration = duration} -- kv
            )
        end

        if unit:HasModifier("m2_sword_slam_debuff") then
            local hBuff = unit:FindModifierByNameAndCaster("m2_sword_slam_debuff", self.caster)
            hBuff:IncrementStackCount()
            local nStackCount = hBuff:GetStackCount()
            damage = damage + ( nStackCount * dmgPerDebuffStack )
        end

        local dmgTable = {
            victim = unit,
            attacker = self.caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
        }

        SendOverheadEventMessage(
            self.caster:GetPlayerOwner(),
            2,
            unit,
            damage,
            nil)

        ApplyDamage(dmgTable)

    end

    -- slam effect
    local nfx = ParticleManager:CreateParticle("particles/warlord/sword_slam_monkey_king_strike.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControlForward(nfx, 0, projectile_direction)
    ParticleManager:SetParticleControl(nfx, 1, vEndPos)
    ParticleManager:ReleaseParticleIndex(nfx)

    -- slam sound
    EmitSoundOn( "Hero_MonkeyKing.Strike.Impact", self:GetCaster() )

end
--------------------------------------------------------------------------------
