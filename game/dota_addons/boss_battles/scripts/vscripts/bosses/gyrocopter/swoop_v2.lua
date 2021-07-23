
swoop_v2 = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "gyro_barrage", "bosses/gyrocopter/gyro_barrage", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "oil_drop_thinker", "bosses/gyrocopter/oil_drop_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gyro_barrage_debuff", "bosses/gyrocopter/modifier_gyro_barrage_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function swoop_v2:OnAbilityPhaseStart()
    if IsServer() then


		if self:GetCursorTarget() then
			self.hTarget = self:GetCursorTarget()
		end

        if self.hTarget then

            -- shoot the fast zap proj
            local info = {
                EffectName = "particles/units/heroes/hero_disruptor/disruptor_base_attack.vpcf",
                Ability = self,
                iMoveSpeed = 3000,
                Source = self:GetCaster(),
                Target = self.hTarget,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            -- shoot proj
            ProjectileManager:CreateTrackingProjectile( info )

            -- sound effect
            self:GetCaster():EmitSound("Hero_Disruptor.Attack")

            -- create modifier on them (stunned with electrical particle effect)
            self.hTarget:AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_generic_stunned", -- modifier name
				{ duration = self:GetSpecialValueFor("barrage_duration") + 1 } -- kv
			)

            self.hTarget:AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_gyro_barrage_debuff", -- modifier name
				{ duration = self:GetSpecialValueFor("barrage_duration") + 1 } -- kv
			)

            self.effect_indicator = ParticleManager:CreateParticle( "particles/gyrocopter/gyro_barrage_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self.hTarget )
            ParticleManager:SetParticleControl( self.effect_indicator, 0, self.hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.effect_indicator, 3, self.hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.effect_indicator, 4, Vector(self:GetSpecialValueFor("barrage_duration") + 1,0,0) )
            ParticleManager:ReleaseParticleIndex(self.effect_indicator)

            self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( 250, -250, -250 ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector(self:GetSpecialValueFor("barrage_duration") + 1,0,0) );
            ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            return true

        end
    end
end

--------------------------------------------------------------------------------

function swoop_v2:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
--------------------------------------------------------------------------------

function swoop_v2:OnSpellStart()
	if IsServer() then

        -- dorp oil timer
        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self:GetCaster()) == false then
                return false
            end

            if self:GetCaster():IsAlive() == false then
                return false
            end

            -- create the modifier thinker
           local puddle = CreateModifierThinker(
            self:GetCaster(),
                self,
                "oil_drop_thinker",
                {
                    target_x = self:GetCaster().x,
                    target_y = self:GetCaster().y,
                    target_z = self:GetCaster().z,
                },
                self:GetCaster():GetAbsOrigin(),
                self:GetCaster():GetTeamNumber(),
                false
            )

            table.insert(_G.Oil_Puddles, puddle)

            return self:GetSpecialValueFor("oil_drop_freq")
        end)

        -- movement
        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.hTarget.x,
                target_y = self.hTarget.y,
                speed = self:GetSpecialValueFor("charge_speed"),
                distance = ( self:GetCaster():GetAbsOrigin() - self.hTarget:GetAbsOrigin() ):Length2D(),
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            Timers:RemoveTimer(self.timer)

            -- add the gyro q modifier
            self:GetCaster():AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"gyro_barrage", -- modifier name
				{ duration = self:GetSpecialValueFor("barrage_duration") } -- kv
			)

            -- play small slam particle effect
            local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_centaur/centaur_warstomp.vpcf', PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(nfx, 1, Vector(400,400,400))
            ParticleManager:SetParticleControl(nfx, 2, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 3, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 4, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 5, self:GetCaster():GetOrigin())
            ParticleManager:ReleaseParticleIndex(nfx)
            self:GetCaster():EmitSound('Hero_Centaur.HoofStomp')

        end)
	end
end
