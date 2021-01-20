m1_beam = class({})

function m1_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
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

        -- init
		self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

        local particleName = "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self.caster )

        --Timers:CreateTimer(function()
            --if IsValidEntity(self.caster) == false then return -1 end

            self.caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )
                if IsValidEntity(self.caster) == false then return -1 end

                ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

                local beam_length = 500
                local vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
                local projectile_direction = (Vector( vTargetPos.x - self.origin.x, vTargetPos.y - self.origin.y, 0 )):Normalized()
                self.beam_point = self:GetCaster():GetAbsOrigin() + projectile_direction * beam_length
                self.beam_point = GetGroundPosition( self.beam_point, nil )
                self.beam_point.z = self.caster:GetAbsOrigin().z + 100

                ParticleManager:SetParticleControl( self.pfx, 1, self.beam_point )

                return 0.01

            end, 0.0 )

            --return 0.01
        --end)

	end
end
----------------------------------------------------------------------------------------------------------------
