timber_droid_support_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function timber_droid_support_thinker:IsHidden()
	return true
end

function timber_droid_support_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function timber_droid_support_thinker:OnCreated( kv )
    if IsServer() then
		-- references
		self.droidsPerLocation = self:GetAbility():GetSpecialValueFor( "droidsPerLocation" )

        --init
        self.parent = self:GetParent()
        self.parentOrgin = self.parent:GetAbsOrigin()
        self.tDroids = {"npc_smelter_droid", "npc_stun_droid", "npc_mine_droid"}
        self.tDroidToSummon = {}
        
        for i = 1, self.droidsPerLocation, 1 do
            table.insert(self.tDroidToSummon, self.tDroids[RandomInt(1,#self.tDroids)])
        end

		-- Play effects
		self:PlayEffects1()
	end
end

function timber_droid_support_thinker:OnDestroy( kv )
	if IsServer() then

		-- Play effects
        self:PlayEffects2()
        GridNav:DestroyTreesAroundPoint( self.parentOrgin, 500, true )
        
        -- summon random droid
        for i = 1, #self.tDroidToSummon, 1 do
            CreateUnitByName( self.tDroidToSummon[i], self.parentOrgin, true, nil, nil, DOTA_TEAM_BADGUYS)
        end

		-- remove thinker
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function timber_droid_support_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Charge"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end
--------------------------------------------------------------------------------

function timber_droid_support_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    EmitSoundOn(sound_cast,self.parent)
end