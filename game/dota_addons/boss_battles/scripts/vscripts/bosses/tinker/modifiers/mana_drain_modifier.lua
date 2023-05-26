mana_drain_modifier = class({})

function mana_drain_modifier:IsHidden()
	return false
end

function mana_drain_modifier:IsDebuff()
	return true
end

function mana_drain_modifier:OnCreated( kv )
    if IsServer() then

        self.mana = 2

        self:StartIntervalThink( 1 )
		self:PlayEffects()
    end
end

function mana_drain_modifier:OnRefresh(table)
    if IsServer() then

    end
end

function mana_drain_modifier:OnDestroy()
    if IsServer() then

        ParticleManager:DestroyParticle(self.effect_cast,true)

        if self:GetParent():HasModifier("mana_drain_root_modifier") then
            self:GetParent():RemoveModifierByName("mana_drain_root_modifier")
        end

    end
end

--------------------------------------------------------------------------------

function mana_drain_modifier:OnIntervalThink()
    if IsServer() then

        if self:GetCaster():GetManaPercent() > 95 or self:GetCaster():IsStunned() then
            self:Destroy()
        end

        self:GetCaster():GiveMana(self.mana)
        BossNumbersOnTarget(self:GetCaster(), self.mana, Vector(75,75,255))

        self:GetParent():Script_ReduceMana(self.mana,nil)

    end
end

function mana_drain_modifier:PlayEffects()
    if IsServer() then
        -- Get Resources
        --local particle_cast = "particles/timber/droid_smelter_lion_spell_mana_drain.vpcf"
        local particle_cast = "particles/units/heroes/hero_wisp/wisp_tether.vpcf"

        -- Create Particle
        self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            1,
            self:GetParent(),
            PATTACH_POINT_FOLLOW,
            "attach_rocket",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )
        ParticleManager:SetParticleControlEnt(
            self.effect_cast,
            0,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )

    end
end

