prison = class({})

LinkLuaModifier("fire_ele_encase_rocks_debuff", "bosses/tinker/modifiers/fire_ele_encase_rocks_debuff", LUA_MODIFIER_MOTION_NONE)

function prison:OnAbilityPhaseStart()
	if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
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

            -- green target particle, on ground


            -- play voice line
			EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------

function prison:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

		--ParticleManager:DestroyParticle(self.head_particle,true)

        -- init
        self.caster = self:GetCaster()
        self.speed = self:GetSpecialValueFor( "speed" )
        self.dmg = self:GetSpecialValueFor( "dmg" )
        
        -- create dummy unit at target location


        -- create projectile
        local info = {
            EffectName = "particles/econ/items/rubick/rubick_ti8_immortal/rubick_ti8_immortal_fade_bolt.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self:GetCaster(),
            Target = self.target,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = 300,
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Zuus.ArcLightning.Cast", self:GetCaster() )

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/rubick/rubick_ti8_immortal/rubick_ti8_immortal_fade_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        
        -- delete the dummmy unit

	end
end
---------------------------------------------------------------------------

function prison:OnProjectileHit( hTarget, vLocation)
	if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            vLocation,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            150,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)

        if units == nil or #units == 0 then return end

        for _, unit in pairs(units) do
            local dmgTable = {
                victim = unit,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(dmgTable)

            -- apply telekinsis lift / rock / prison
            local hRocks = CreateUnitByName( "npc_encase_rocks", vLocation, false, nil, nil, DOTA_TEAM_BADGUYS)
            hRocks:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

            hTarget:AddNewModifier( self:GetCaster(), self, "fire_ele_encase_rocks_debuff", { duration = -1 } )
            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = -1 } )
        end
	end
end
---------------------------------------------------------------------------