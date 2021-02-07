e_whirling_winds_modifier_thinker = class({})

function e_whirling_winds_modifier_thinker:IsHidden()
	return false
end

function e_whirling_winds_modifier_thinker:IsDebuff()
	return false
end

function e_whirling_winds_modifier_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function e_whirling_winds_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        self:PlayEffects()

        EmitSoundOn("n_creep_Wildkin.Tornado", self:GetParent())

        self.interval = 0.03
        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function e_whirling_winds_modifier_thinker:OnIntervalThink()
    if IsServer() then

        local friendlies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if friendlies ~= nil and #friendlies ~= 0 then
            for _, friend in pairs(friendlies) do
                friend:AddNewModifier(self.parent, self, "e_whirling_winds_modifier", { duration = 2.0 })
            end
        end

    end
end
---------------------------------------------------------------------------

function e_whirling_winds_modifier_thinker:PlayEffects()
    if IsServer() then

        local particle = "particles/ranger/ranger_tornado_ambient.vpcf"

        self.nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.nfx, 0, self.currentTarget)

        local outline_particle = "particles/ranger/ranger_winds_hero_snapfire_ultimate_calldown_ring.vpcf"
        self.nfx_outline = ParticleManager:CreateParticle(outline_particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl(self.nfx_outline, 0, self.currentTarget)
        ParticleManager:SetParticleControl(self.nfx_outline, 1, Vector(self.radius,1,1))

	end
end
---------------------------------------------------------------------------

function e_whirling_winds_modifier_thinker:OnDestroy( kv )
    if IsServer() then
        self.parent:StopSound("n_creep_Wildkin.Tornado")
        ParticleManager:DestroyParticle(self.nfx,false)
        ParticleManager:DestroyParticle(self.nfx_outline,false)
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------