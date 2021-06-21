roar = class({})

LinkLuaModifier( "modifier_roar", "bosses/beastmaster/modifier_roar", LUA_MODIFIER_MOTION_NONE )

function roar:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 0.20)

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = self:GetCastPoint() + self:GetSpecialValueFor( "duration" ) } )

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
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
            self.distance = 2500

            -- play voice line
            EmitSoundOn("Hero_Beastmaster.Primal_Roar", self:GetCaster())

            self.radius = 380
            local particle = "particles/custom/mouse_range_static/range_finder_cone.vpcf"
            self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW,  units[1])
    
            ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
            ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
            ParticleManager:SetParticleControl(self.particleNfx , 2, ( self:GetCaster():GetAbsOrigin() + ( self.direction * self.distance ) )) -- target
            ParticleManager:SetParticleControl(self.particleNfx , 3, Vector( self.radius,self.radius,0) ) -- line width
            ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

            return true
        end

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function roar:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

        if self.particleNfx then
            ParticleManager:DestroyParticle(self.particleNfx,true)
        end

    end
end
---------------------------------------------------------------------------

function roar:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    local count = 0

    Timers:CreateTimer(function()
        if IsValidEntity(caster) == false then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        if count == duration then
            if self.particleNfx then
                ParticleManager:DestroyParticle(self.particleNfx,true)
            end
            return false
        end

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        self.units = FindUnitsInLine(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            self:GetCaster():GetAbsOrigin() + ( self.direction * self.distance ),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

        local particle = ParticleManager:CreateParticle("particles/beastmaster/beasmtaterbm_shoulder_ti7_roar.vpcf", PATTACH_WORLDORIGIN,nil)
        ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, self.vTargetPos)
        ParticleManager:ReleaseParticleIndex(particle)

        if self.units ~= nil and #self.units ~= 0 then
            for _, unit in pairs(self.units) do
                unit:AddNewModifier(self:GetCaster(), self, "modifier_roar", {duration = 0.2})
                unit:AddNewModifier(self:GetCaster(), self, "modifier_generic_silenced", {duration = 1})
            end
        end

        count = count + 0.5
        return 0.5
    end)
end