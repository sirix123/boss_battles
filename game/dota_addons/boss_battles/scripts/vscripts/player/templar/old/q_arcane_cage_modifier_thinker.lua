q_arcane_cage_modifier_thinker = class({})

function q_arcane_cage_modifier_thinker:IsHidden()
	return true
end

function q_arcane_cage_modifier_thinker:IsDebuff()
	return false
end

function q_arcane_cage_modifier_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function q_arcane_cage_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        local particle = "particles/templar/templar_naga_siren_song_aura.vpcf"
        self.particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(
            self.particle,
            0,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            Vector(0, 0, 0), -- unknown
            true -- unknown, true
        )

        self:StartIntervalThink(0.03 )
	end
end
---------------------------------------------------------------------------

function q_arcane_cage_modifier_thinker:OnIntervalThink()
    if IsServer() then

        -- find allies
        local allies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetParent():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self:GetAbility():GetSpecialValueFor( "radius" ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if allies ~= nil and #allies ~= 0  then
            for _, ally in pairs(allies) do
                ally:AddNewModifier(
                    self:GetCaster(), -- player source
                    self:GetAbility(), -- ability source
                    "q_arcane_cage_modifier", -- modifier name
                    {duration = 1} -- kv
                )
            end
        end
    end
end
---------------------------------------------------------------------------

function q_arcane_cage_modifier_thinker:OnDestroy( kv )
    if IsServer() then

        if self.particle then
            ParticleManager:DestroyParticle(self.particle,false)
        end

        self:StartIntervalThink( -1 )
	end
end
---------------------------------------------------------------------------