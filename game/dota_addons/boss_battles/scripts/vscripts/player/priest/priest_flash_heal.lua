priest_flash_heal = class({})

function priest_flash_heal:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("space_angel_mode_modifier") then
        return ability_cast_point - ( ability_cast_point * caster:FindAbilityByName("space_angel_mode"):GetSpecialValueFor( "reduce_cps" ) )
    else
        return ability_cast_point
    end
end

function priest_flash_heal:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        else

            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
                bMovementLock = true,
            })

            self.target = units[1]

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

            local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf"
            local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControlEnt(particle_cast_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(particle_cast_fx, 1, self.target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)

            return true
        end
    end
end
---------------------------------------------------------------------------

function priest_flash_heal:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

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

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- init
        self.caster = self:GetCaster()

        self.target:Heal(self:GetSpecialValueFor( "heal_amount" ),self.caster)

        self.reduce_healing = 100 / self.caster:FindAbilityByName("priest_inner_fire"):GetSpecialValueFor( "healing_reduce_target" )

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units ~= nil or #units ~= 0 then
            for _, unit in pairs(units) do
                if unit:HasModifier("priest_inner_fire_modifier") then
                    unit:Heal(self:GetSpecialValueFor( "heal_amount" ) / self.reduce_healing ,self.caster)
                end
            end
        end

        self.false_promise_cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
        ParticleManager:SetParticleControl(self.false_promise_cast_particle, 2, self.target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(self.false_promise_cast_particle)

        -- Create Sound
        self.target:EmitSound("Hero_Oracle.FalsePromise.Cast")

	end
end
----------------------------------------------------------------------------------------------------------------
