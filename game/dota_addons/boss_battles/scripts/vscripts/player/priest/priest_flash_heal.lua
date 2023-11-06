priest_flash_heal = class({})

function priest_flash_heal:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("space_angel_mode_modifier") == true then
        return ability_cast_point - ( ability_cast_point * caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_cps" ) )
    else
        return ability_cast_point
    end
end

function priest_flash_heal:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function priest_flash_heal:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function priest_flash_heal:GetManaCost(level)
	local caster = self:GetCaster()
	local modifier = "space_angel_mode_modifier"
	local base_mana_cost = self.BaseClass.GetManaCost(self, level)

    local mana_cost = base_mana_cost

	if caster:HasModifier(modifier) then
		--mana_cost = base_mana_cost / caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_mana_cost" )
        mana_cost = 0
	end

	return mana_cost
end
---------------------------------------------------------------------------

function priest_flash_heal:OnSpellStart()
    if IsServer() then

        -- init
        self.caster = self:GetCaster()

        self:GetCursorTarget():Heal(self:GetSpecialValueFor( "heal_amount" ),self.caster)

        self.reduce_healing = 100 / self.caster:FindAbilityByName("priest_inner_fire"):GetSpecialValueFor( "healing_reduce_target" )

        if self:GetCursorTarget():HasModifier("priest_inner_fire_modifier") then
            self:GetCursorTarget():Heal(self:GetSpecialValueFor( "heal_amount" ) / self.reduce_healing ,self.caster)
        end

        self.false_promise_cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCursorTarget())
        ParticleManager:SetParticleControl(self.false_promise_cast_particle, 2, self:GetCursorTarget():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(self.false_promise_cast_particle)

        -- Create Sound
        self:GetCursorTarget():EmitSound("Hero_Oracle.FalsePromise.Cast")

	end
end
----------------------------------------------------------------------------------------------------------------
