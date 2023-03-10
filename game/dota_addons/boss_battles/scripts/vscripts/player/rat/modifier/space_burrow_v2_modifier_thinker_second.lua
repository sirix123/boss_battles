space_burrow_v2_modifier_thinker_second = class({})
LinkLuaModifier( "space_burrow_v2_modifier", "player/rat/modifier/space_burrow_v2_modifier", LUA_MODIFIER_MOTION_NONE )

function space_burrow_v2_modifier_thinker_second:IsHidden()
	return true
end

function space_burrow_v2_modifier_thinker_second:IsDebuff()
	return false
end

function space_burrow_v2_modifier_thinker_second:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function space_burrow_v2_modifier_thinker_second:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.interval = FrameTime()
        self.radius = kv.radius
        self.location = (Vector(kv.target_x,kv.target_y,kv.target_z))
        self.location_first = (Vector(kv.target_x_first,kv.target_y_first,kv.target_z_first))
        self.duration_cooldown = kv.duration_cooldown

        --DebugDrawCircle(self.location,Vector(255,0,0),128,self.radius,true,60)
        --DebugDrawCircle(self.location_first ,Vector(255,0,0),128,self.radius,true,60)

        local particle = "particles/rat/rat_meepo_burrow.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl(self.effect_cast, 0, self.location)
        ParticleManager:SetParticleControl(self.effect_cast, 2, self.location)

        particle = "particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf"
        self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl(self.effect_cast_1, 0, self.location)
        ParticleManager:SetParticleControl(self.effect_cast_1, 2, self.location)

        particle = "particles/rat/rat_teleport_spring_2021_rays.vpcf"
        self.effect_cast_2 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast_2, 0, self.location)

        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function space_burrow_v2_modifier_thinker_second:OnIntervalThink()
    if IsServer() then

        local friendlies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self.location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if friendlies ~= nil and #friendlies ~= 0 then
            for _, friend in pairs(friendlies) do

                if friend:HasModifier("space_burrow_v2_modifier") == false then
                    Timers:CreateTimer(0.2,function()
                        FindClearSpaceForUnit(friend, self.location_first, false)
                        return false
                    end)
                end

                if friend:HasModifier("space_burrow_v2_modifier") == false then

                    friend:AddNewModifier(
                        friend, -- player source
                        nil, -- ability source
                        "space_burrow_v2_modifier", -- modifier name
                        { duration = self.duration_cooldown } -- kv
                    )

                end

            end
		end

    end
end
---------------------------------------------------------------------------

function space_burrow_v2_modifier_thinker_second:OnDestroy( kv )
    if IsServer() then
        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end
        if self.effect_cast_1 then
            ParticleManager:DestroyParticle(self.effect_cast_1,true)
        end
        if self.effect_cast_2 then
            ParticleManager:DestroyParticle(self.effect_cast_2,true)
        end
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------