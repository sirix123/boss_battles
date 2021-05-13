link_crystals_tinker = class({})

LinkLuaModifier("link_crystals_modifier", "bosses/tinker/modifiers/link_crystals_modifier", LUA_MODIFIER_MOTION_NONE)

function link_crystals_tinker:OnAbilityPhaseStart()
	if IsServer() then
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            self.tParticles = {}

            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_phase2_crystal" then
                    self.target = unit

                    local particle = "particles/tinker/tinker_disruptor_thunder_strike_buff.vpcf"
                    self.overhead_nfx = ParticleManager:CreateParticle( particle, PATTACH_OVERHEAD_FOLLOW, self.target )
                    ParticleManager:SetParticleControl( self.overhead_nfx, 0, self.target:GetAbsOrigin())
                    ParticleManager:SetParticleControl( self.overhead_nfx, 1, self.target:GetAbsOrigin())
                    table.insert(self.tParticles,self.overhead_nfx )

                end
            end

            -- play voice line
			EmitSoundOn("tinker_tink_cast_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------

function link_crystals_tinker:OnSpellStart()
    if IsServer() then

        for _, particle in pairs(self.tParticles) do
            if particle then
                ParticleManager:DestroyParticle(particle, true)
            end
        end

        if self.target:HasModifier("link_crystals_modifier") then
            self.target:RemoveModifierByName("link_crystals_modifier")
        end

        if self.target then
            self.target:AddNewModifier( self.target, self, "link_crystals_modifier", { duration = 30, target = self.target:GetEntityIndex() } )
        end

	end
end
---------------------------------------------------------------------------