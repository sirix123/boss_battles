
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

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            local radius = 150
            --[[self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
            --ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )]]

            local direction = (self.vTargetPos - self:GetCaster():GetAbsOrigin() ):Normalized()

            local particle = "particles/custom/ui_mouseactions/range_finder_cone_body_only.vpcf"
            self.nPreviewFXIndex = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, self:GetCaster():GetAbsOrigin() + (direction * 1600))
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, self:GetCaster():GetAbsOrigin() );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 3, Vector( radius, radius, 0 ) );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 4, Vector( 255, 0, 0 ) );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 6, Vector( 1, 0, 0 ) );

            -- play voice line
            EmitSoundOn("shredder_timb_cast_03", self:GetCaster())

            return true
        end
    end
end


function blast_wave_v2:OnSpellStart()
    if IsServer() then

        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

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