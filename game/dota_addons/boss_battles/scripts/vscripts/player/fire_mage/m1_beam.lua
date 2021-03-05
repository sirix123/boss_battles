m1_beam = class({})
LinkLuaModifier( "m1_beam_fire_rage", "player/fire_mage/modifiers/m1_beam_fire_rage", LUA_MODIFIER_MOTION_NONE )

function m1_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = -1,
            bMovementLock = true,
            bTurnRateLimit = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_beam:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_beam:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        -- init
		self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.beam_width = 100
        local dmg = 50
        local channel_time_buff = 3
        self.proj_damage = 100

        self.beam_point = Vector(0,0,0)
        local particleName = "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self.caster )

        -- particle effect timer
        Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then return false end

            if self.caster.left_mouse_up_down == 1 then
                self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
                ParticleManager:DestroyParticle(self.pfx,true)
                return false
            end

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

            local beam_length = 500
            local caster_forward = self.caster:GetForwardVector()
            self.beam_point = self.origin + caster_forward * beam_length
            self.beam_point = GetGroundPosition( self.beam_point, nil )
            self.beam_point.z = self.beam_point.z + 100

            ParticleManager:SetParticleControl( self.pfx, 1, self.beam_point )

            return 0.03

        end)

        -- dmg timer
        Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then return false end

            if self.caster.left_mouse_up_down == 1 then
                return false
            end

            local units = FindUnitsInLine(
                        self:GetCaster():GetTeamNumber(),
                        self:GetCaster():GetAbsOrigin(),
                        self.beam_point,
                        nil,
                        self.beam_width,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE)

                    if units ~= nil and #units ~= 0 then
                        for _,unit in pairs(units) do
                            local damage = {
                                victim = unit,
                                attacker = self:GetCaster(),
                                damage = dmg,
                                damage_type = DAMAGE_TYPE_PHYSICAL,
                                ability = self
                            }
                            ApplyDamage( damage )
                        end
                    end

            return 0.5
        end)

        -- buff timer
        local j = 0
        Timers:CreateTimer(1,function()
            if IsValidEntity(self.caster) == false then return false end

            if self.caster.left_mouse_up_down == 1 then
                j = 0
                return false
            end

            if j == channel_time_buff then
                j = 0
                self.caster:AddNewModifier(self.caster,self,"m1_beam_fire_rage", { duration = 30 })
                self:Proj( self.beam_point )
            end
            j = j + 1
            return 1
        end)

	end
end
----------------------------------------------------------------------------------------------------------------

function m1_beam:Proj( location )
    if IsServer() then

        EmitSoundOn( "Hero_Lina.attack", self:GetCaster() )

        local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.beam_width,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

        if enemies ~= nil and #enemies ~= 0 then
            for _,enemy in pairs(enemies) do
                local info = {
                    EffectName = "particles/units/heroes/hero_lina/lina_base_attack.vpcf",
                    Ability = self,
                    iMoveSpeed = 800,
                    Source = self.caster,
                    Target = enemy,
                    bDodgeable = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                    bProvidesVision = true,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                    iVisionRadius = 300,
                }

                ProjectileManager:CreateTrackingProjectile( info )
            end
        end
    end
end
----------------------------------------------------------------------------------------------------------------

function m1_beam:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        self.damageTable = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = self.proj_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }

        ApplyDamage(self.damageTable)

        EmitSoundOn( "Hero_Lina.ProjectileImpact", hTarget )

    end
end

