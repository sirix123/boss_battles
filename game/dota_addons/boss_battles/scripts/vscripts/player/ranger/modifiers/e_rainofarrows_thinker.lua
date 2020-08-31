
e_rainofarrows_thinker = class({})

function e_rainofarrows_thinker:OnCreated( kv )
	local interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if IsServer() then
		-- precache damage
		self.damage = self.damage*interval/kv.duration
		self.damageTable = {
			attacker = self:GetCaster(),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}

		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()

		-- play effects
		self:PlayEffects( self.radius, kv.duration, interval )
	end
end

function e_rainofarrows_thinker:OnRemoved()
end

function e_rainofarrows_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
function e_rainofarrows_thinker:OnIntervalThink()
    
    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	
		self:GetParent():GetOrigin(),
		nil,	
		self.radius,	
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #enemies<1 then return end
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		self.damageTable.damage = self.damage/#enemies
		ApplyDamage( self.damageTable )
	end
end

--------------------------------------------------------------------------------
function e_rainofarrows_thinker:PlayEffects( radius, duration, interval )
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf"
    local sound_cast = "Hero_SkywrathMage.MysticFlare"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, duration, interval ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetParent() )
end