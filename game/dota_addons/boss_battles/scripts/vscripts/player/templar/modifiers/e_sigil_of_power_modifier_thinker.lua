e_sigil_of_power_modifier_thinker = class({})

function e_sigil_of_power_modifier_thinker:IsHidden()
	return true
end

function e_sigil_of_power_modifier_thinker:IsDebuff()
	return false
end

function e_sigil_of_power_modifier_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function e_sigil_of_power_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        self:PlayEffects()

        self.interval = 0.03
        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function e_sigil_of_power_modifier_thinker:OnIntervalThink()
    if IsServer() then

        local friendlies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if friendlies ~= nil and #friendlies ~= 0 then
            for _, friend in pairs(friendlies) do

                if friend:HasModifier("e_sigil_of_power_modifier") == false then
                    friend:AddNewModifier(self.parent, self:GetAbility(), "e_sigil_of_power_modifier",
                    {
                        duration = self:GetAbility():GetSpecialValueFor("duration"),
                    })
                end

            end
        end

    end
end
---------------------------------------------------------------------------

function e_sigil_of_power_modifier_thinker:PlayEffects()
    if IsServer() then

        local particle = "particles/custom/magic_circle/magic_circle.vpcf"

        self.nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.nfx, 0, self.currentTarget)
        ParticleManager:SetParticleControl(self.nfx, 2, Vector(self.radius,0,0))

	end
end
---------------------------------------------------------------------------

function e_sigil_of_power_modifier_thinker:OnDestroy( kv )
    if IsServer() then

        if self.nfx then
            ParticleManager:DestroyParticle(self.nfx,false)
        end

        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------