assistant_sweep = class({})
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

function assistant_sweep:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.3)

        self.vTargetPos = nil
		if self:GetCursorTarget() then
			self.vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			self.vTargetPos = self:GetCursorPosition()
        end

        self.spell_width = 200
        self.start_pos = self:GetAbsOrigin() + self:GetForwardVector() * 100

        local particle = "particles/custom/sirix_mouse/range_finder_cone_nohead.vpcf"
        self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
        ParticleManager:SetParticleControl(self.particleNfx , 1, self.start_pos) -- origin
        ParticleManager:SetParticleControl(self.particleNfx , 2, self.vTargetPos)  -- target
		ParticleManager:SetParticleControl(self.particleNfx , 3, Vector(self.spell_width,self.spell_width,0)) -- line width
		ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function assistant_sweep:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
    self.caster = self:GetCaster()

    -- indicator
    ParticleManager:DestroyParticle(self.particleNfx,true)

    -- spell
    local particle = "particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf"

    --[[ left particle
    local nfx_1 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
    local left_start = self:GetAbsOrigin() - self.caster:GetRightVector() * 100
    local left_end = self:GetAbsOrigin() - self.caster:GetRightVector() * 600
    ParticleManager:SetParticleControl(nfx_1, 0, left_start)
	ParticleManager:SetParticleControl(nfx_1, 1, left_end)
    ParticleManager:SetParticleControl(nfx_1, 2, Vector(0.5, 0, 0 ))]]

    -- middle particel
    local nfx_2 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(nfx_2, 0, self.start_pos)
	ParticleManager:SetParticleControl(nfx_2, 1, self.vTargetPos)
    ParticleManager:SetParticleControl(nfx_2, 2, Vector(0.5, 0, 0 ))

    --[[ right particle
    local nfx_3 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetCaster())
    local right_start = self:GetAbsOrigin() + self.caster:GetRightVector() * 100
    local right_end = self:GetAbsOrigin() + self.caster:GetRightVector() * 600
    ParticleManager:SetParticleControl(nfx_3, 0, right_start)
	ParticleManager:SetParticleControl(nfx_3, 1, right_end)
    ParticleManager:SetParticleControl(nfx_3, 2, Vector(0.5, 0, 0 ))]]

    local units = FindUnitsInLine(self:GetCaster():GetTeam(), self.start_pos, self.vTargetPos, nil, self.spell_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)

    for _,unit in ipairs(units) do

        unit:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_stunned", -- modifier name
            { duration = 2 } -- kv
        )

		ApplyDamage({
			victim = unit,
			attacker = self:GetCaster(),
			damage = 250,
			damage_type = DAMAGE_TYPE_PHYSICAL
		})
	end


end