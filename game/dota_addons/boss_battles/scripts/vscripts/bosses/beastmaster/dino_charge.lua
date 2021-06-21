
dino_charge = class({})
LinkLuaModifier("grab_player_modifier_dino", "bosses/beastmaster/grab_player_modifier_dino", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function dino_charge:OnAbilityPhaseStart()
    if IsServer() then

        self.target = self:GetCursorTarget()

        -- stomp floor, play animation
        self.animation_timer = Timers:CreateTimer(function()
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 0.1)
            EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), "Hero_Centaur.HoofStomp", self:GetCaster() )
            local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_centaur/centaur_warstomp.vpcf', PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(nfx, 1, Vector(100,100,100))
            ParticleManager:SetParticleControl(nfx, 2, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 3, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 4, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 5, self:GetCaster():GetOrigin())
            ParticleManager:ReleaseParticleIndex(nfx)
            return 1
        end)

        return true
    end
end

--------------------------------------------------------------------------------

function dino_charge:OnAbilityPhaseInterrupted()
	if IsServer() then

        if self.animation_timer ~= nil then
            Timers:RemoveTimer(self.animation_timer)
            self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
        end



        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx, true)
        end

    end
end

function dino_charge:OnSpellStart()
	if IsServer() then

        if self.animation_timer ~= nil then
            Timers:RemoveTimer(self.animation_timer)
            self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
        end

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx, true)
        end

        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self:GetCaster()) == false then
                return false
            end

            if self:GetCaster():IsAlive() == false then
                return false
            end

            local units = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                self:GetCaster():GetAbsOrigin(),	-- point, center point self:GetCaster():GetAbsOrigin()
                nil,	-- handle, cacheUnit. (not known)
                150,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if units ~= nil and #units ~= 0 then
                for _, unit in pairs(units) do
                        self.damageTable = {
                            attacker = self:GetCaster(),
                            victim = unit,
                            damage = 350,
                            damage_type = self:GetAbilityDamageType(),
                            ability = self,
                        }

                        ApplyDamage( self.damageTable )
                end
            end

            return 0.1
        end)

        local distance = ( self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin() ):Length2D()

        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.target.x,
                target_y = self.target.y,
                distance = distance,
                speed = 1500,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            Timers:RemoveTimer(self.timer)

            local units = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                self:GetCaster():GetAbsOrigin(),	-- point, center point self:GetCaster():GetAbsOrigin()
                nil,	-- handle, cacheUnit. (not known)
                150,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if units ~= nil and #units ~= 0 then
                units[1]:AddNewModifier(self:GetCaster(), self, "grab_player_modifier_dino", { duration= -1, })
            end

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
