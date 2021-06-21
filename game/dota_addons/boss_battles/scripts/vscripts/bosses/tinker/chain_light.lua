chain_light = class({})

LinkLuaModifier( "chain_light_modifier", "bosses/tinker/modifiers/chain_light_modifier", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "cast_electric_field", "bosses/tinker/modifiers/cast_electric_field", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "electric_encase_rocks", "bosses/tinker/modifiers/electric_encase_rocks", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_generic_stunned", "bosses/core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "chain_light_buff_elec", "bosses/tinker/modifiers/chain_light_buff_elec", LUA_MODIFIER_MOTION_NONE  )

function chain_light:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local random_unit = RandomInt(1, #units)

            self.vTargetPos = units[random_unit]:GetAbsOrigin()
            self.target = units[random_unit]

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            local particle = "particles/tinker/elec_overhead_icon.vpcf"
            self.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.target)
            ParticleManager:SetParticleControl(self.head_particle, 0, self.target:GetAbsOrigin())

            -- play voice line
            --EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function chain_light:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        self:GetCaster():EmitSound("Hero_Zuus.ArcLightning.Cast")

        ParticleManager:DestroyParticle(self.head_particle,true)

        local head_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(head_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(head_particle, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(head_particle)

        self.target:AddNewModifier(caster, self, "chain_light_modifier",
        {
			unit = self.target:entindex()
		})

    end
end
