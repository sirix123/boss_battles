laser = class({})

--------------------------------------------------------------------------------
-- Ability Phase Start
function laser:OnAbilityPhaseStart()
    if IsServer() then
        --self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self.nPreviewFXIndex = nil
        self.stopTimer = false

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local random_unit = RandomInt(1, #units)
            self.target = units[random_unit]

            Timers:CreateTimer(FrameTime(), function()
                if self.stopTimer == true then
                    return false
                end

                if self.nPreviewFXIndex == nil then
                    local particle = "particles/custom/ui_mouseactions/range_finder_cone_body_only_v2.vpcf" --"particles/targeting/line_base.vpcf"
                    self.nPreviewFXIndex = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
                end

                self.vTargetPos = self.target:GetAbsOrigin()

                self:GetCaster():SetForwardVector(( self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized())
                self:GetCaster():FaceTowards(( self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized())

                -- draw a line between tinker and the player

                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, self.vTargetPos)
                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, self:GetCaster():GetAbsOrigin() );
                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 3, Vector( 20, 20, 0 ) );
                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 4, Vector( 255, 0, 0 ) );
                ParticleManager:SetParticleControl( self.nPreviewFXIndex, 6, Vector( 1, 0, 0 ) );

                return FrameTime()
            end)

            -- effects
            local sound_cast = "Hero_Tinker.LaserAnim"
            EmitSoundOn( sound_cast, self:GetCaster() )

            return true -- if success
        end
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function laser:OnSpellStart()
    if IsServer() then
        --self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
        self.stopTimer = true
        ParticleManager:DestroyParticle(self.nPreviewFXIndex,true)

        -- unit identifier
        local caster = self:GetCaster()

        -- load data
        local damage = 100--self:GetSpecialValueFor("laser_damage")
        local index = 1

        -- check if there is a rock or crystal between the player and the caster
        local units = FindUnitsInLine(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            self.vTargetPos,
            nil,
            1,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

        --DebugDrawLine_vCol(caster:GetAbsOrigin(), self.vTargetPos , Vector(255,0,0), true, 2)

        if units ~= nil and #units ~= 0 then
            --print(" unit:GetUnitName()" ,units[index]:GetUnitName())
            --print(" -------------------------------------- ")

            if units[index]:GetUnitName() == caster:GetUnitName() then
                index = 2
            end


            if units[index]:GetUnitName() ~= caster:GetUnitName() then
                --if unit:GetUnitName() == "npc_phase2_rock" then -- rock
                if units[index]:GetUnitName() == "npc_phase2_rock" then -- rock
                    self:PlayEffects( units[index]  ) -- laser effects

                    -- explode rock
                    local explode_rock = "particles/econ/events/ti10/hot_potato/hot_potato_explode.vpcf"
                    local explode_rock_index = ParticleManager:CreateParticle( explode_rock, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index, 0, units[index]:GetAbsOrigin() )
                    ParticleManager:SetParticleControl( explode_rock_index, 1, Vector(0,0,100))
                    --ParticleManager:SetParticleControl( explode_rock_index, 1, Vector(255,0,0))
                    ParticleManager:ReleaseParticleIndex(explode_rock_index)

                    local explode_rock_2 = "particles/tinker/tinker_dire_tower_attack_explode.vpcf"
                    local explode_rock_index_2 = ParticleManager:CreateParticle( explode_rock_2, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index_2, 3, units[index]:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(explode_rock_index_2)

                    local vLava = Vector(units[index]:GetAbsOrigin().x, units[index]:GetAbsOrigin().y, units[index]:GetAbsOrigin().z )
                    vLava.z = vLava.z + 200
                    local explode_rock_3 = "particles/tinker/tinker_lion_spell_impale_ti9_lava.vpcf"
                    local explode_rock_index_3 = ParticleManager:CreateParticle( explode_rock_3, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index_3, 3, vLava)
                    ParticleManager:ReleaseParticleIndex(explode_rock_index_3)

                    units[index]:RemoveSelf()

                elseif units[index]:GetUnitName() == "npc_phase2_crystal" then -- crystal

                    self:PlayEffects( units[index]  ) -- laser effects

                    -- explode rock
                    local explode_rock = "particles/econ/events/ti10/hot_potato/hot_potato_explode.vpcf"
                    local explode_rock_index = ParticleManager:CreateParticle( explode_rock, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index, 0,units[index]:GetAbsOrigin() )
                    ParticleManager:SetParticleControl( explode_rock_index, 1, Vector(0,0,100))
                    --ParticleManager:SetParticleControl( explode_rock_index, 1, Vector(255,0,0))
                    ParticleManager:ReleaseParticleIndex(explode_rock_index)

                    local explode_rock_2 = "particles/tinker/tinker_dire_tower_attack_explode.vpcf"
                    local explode_rock_index_2 = ParticleManager:CreateParticle( explode_rock_2, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index_2, 3, units[index]:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(explode_rock_index_2)

                    local vLava = Vector(units[index]:GetAbsOrigin().x, units[index]:GetAbsOrigin().y, units[index]:GetAbsOrigin().z )
                    vLava.z = vLava.z + 200
                    local explode_rock_3 = "particles/tinker/tinker_lion_spell_impale_ti9_lava.vpcf"
                    local explode_rock_index_3 = ParticleManager:CreateParticle( explode_rock_3, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl( explode_rock_index_3, 3, vLava)
                    ParticleManager:ReleaseParticleIndex(explode_rock_index_3)

                    units[index]:RemoveSelf()

                elseif units[index]:GetUnitName() ~= "npc_phase2_rock" and units[index]:GetUnitName() ~= "npc_phase2_crystal" and units[index]:GetUnitName() ~= caster:GetUnitName() then -- player
                    local dmgTable = {
                        victim = units[index],
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = self
                    }

                    ApplyDamage( dmgTable )
                    self:PlayEffects( units[index]  ) -- laser effects

                end
            end
        end
    end
end

--------------------------------------------------------------------------------
function laser:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_tinker/tinker_laser.vpcf"
	local sound_cast = "Hero_Tinker.Laser"
	local sound_target = "Hero_Tinker.LaserImpact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	local attach = "attach_attack1"
	if self:GetCaster():ScriptLookupAttachment( "attach_attack2" )~=0 then attach = "attach_attack2" end
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		9,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		attach,
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end