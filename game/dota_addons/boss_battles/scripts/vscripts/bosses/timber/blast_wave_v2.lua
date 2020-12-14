
blast_wave_v2 = class({})

LinkLuaModifier( "timber_blast_thinker", "bosses/timber/timber_blast_thinker", LUA_MODIFIER_MOTION_NONE )

function blast_wave_v2:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            2500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            self.vTargetPos = units[1]:GetAbsOrigin()

            local direction = ( units[1]:GetAbsOrigin() - self:GetCaster():GetAbsOrigin() ):Normalized()
            local distance = 1950

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            local radius = 150
            local particle = "particles/custom/mouse_range_static/range_finder_cone.vpcf"
            self.particleNfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW,  units[1])
    
            ParticleManager:SetParticleControl(self.particleNfx , 0, Vector(0,0,0))
            ParticleManager:SetParticleControl(self.particleNfx , 1, self:GetCaster():GetAbsOrigin()) -- origin
            ParticleManager:SetParticleControl(self.particleNfx , 2, ( self:GetCaster():GetAbsOrigin() + ( direction * distance ) )) -- target
            ParticleManager:SetParticleControl(self.particleNfx , 3, Vector( radius,radius,0) ) -- line width
            ParticleManager:SetParticleControl(self.particleNfx , 4, Vector(255,0,0)) -- colour

            -- play voice line
            EmitSoundOn("shredder_timb_cast_03", self:GetCaster())

            return true
        end
    end
end

function blast_wave_v2:OnAbilityPhaseInterrupted()
    if IsServer() then
        ParticleManager:DestroyParticle(self.particleNfx, true)

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT_END)
    end
end

function blast_wave_v2:OnSpellStart()
    if IsServer() then

        ParticleManager:DestroyParticle(self.particleNfx, true)

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT_END)

        -- init
		self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.radius = 150
        self.explode_delay = 0.5
        self.spawn_delay = 0.5
        self.damage = 500
        local tSunStrikes = {}

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        local projectile_direction = self.vTargetPos-self.caster:GetAbsOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()

        -- line length
        local length = 1950

        -- sun strike raidus
        local nSunStrikes = length / self.radius

        -- fit sunstrikes along long
        for i = 1, nSunStrikes, 1 do
            local offset = i * self.radius
            local vLoc = Vector( self.caster:GetAbsOrigin().x + ( offset * projectile_direction.x ), self.caster:GetAbsOrigin().y + ( offset * projectile_direction.y ), 132)
            --DebugDrawCircle(vRock, Vector(0,155,0),128,50,true,60)
            table.insert(tSunStrikes, vLoc)
        end

        -- create modifier thinker on each line with delay inbetween
        local i = 1

        -- timer
        Timers:CreateTimer(self.spawn_delay, function()
            if i == nSunStrikes then
                return false
            end

            CreateModifierThinker(
                self.caster,
                self,
                "timber_blast_thinker",
                {
                    duration = self.explode_delay,
                    radius = self.radius,
                },
                tSunStrikes[i],
                self.caster:GetTeamNumber(),
                false
            )

            i = i + 1
            return self.spawn_delay
        end)
	end
end
------------------------------------------------------------------------------------------------