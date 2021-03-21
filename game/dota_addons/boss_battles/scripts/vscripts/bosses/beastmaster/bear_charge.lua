
bear_charge = class({})
LinkLuaModifier("bear_charge_pushback_modifier", "bosses/beastmaster/bear_charge_pushback_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function bear_charge:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self:GetSpecialValueFor("charge_length"),	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local randomEnemy = units[RandomInt(1, #units)]

            self.vTargetPos = randomEnemy:GetAbsOrigin()

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            self.direction = ( randomEnemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin() ):Normalized()
            self.distance = self:GetSpecialValueFor("charge_length")

            self.radius = 150
            local particle = "particles/custom/mouse_range_static/range_finder_cone.vpcf"
            self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW,  randomEnemy)

            self.vPos = self:GetCaster():GetAbsOrigin() + ( self.direction * self.distance )

            ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
            ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
            ParticleManager:SetParticleControl(self.particleNfx , 2, self.vPos) -- target
            ParticleManager:SetParticleControl(self.particleNfx , 3, Vector( self.radius,self.radius,0) ) -- line width
            ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

            return true
        end
    end
end

--------------------------------------------------------------------------------

function bear_charge:OnAbilityPhaseInterrupted()
	if IsServer() then

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx, true)
        end

    end
end

function bear_charge:OnSpellStart()
	if IsServer() then

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx, true)
        end

        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.vPos.x,
                target_y = self.vPos.y,
                distance = self:GetSpecialValueFor("charge_length"),
                speed = self:GetSpecialValueFor("charge_speed"),
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            -- stun self and players
            local units = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                self:GetCaster():GetAbsOrigin(),	-- point, center point self:GetCaster():GetAbsOrigin()
                nil,	-- handle, cacheUnit. (not known)
                400,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if units ~= nil and #units ~= 0 then
                for _, unit in pairs(units) do
                    unit:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "bear_charge_pushback_modifier", -- modifier name
                        {
                            duration = 1,
                        }
                    )

                    unit:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "modifier_stunned", -- modifier name
                        {
                            duration = 3,
                        }
                    )
                end
            end

            -- stun bear
            self:GetCaster():AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_stunned", -- modifier name
                {
                    duration = 3,
                }
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
