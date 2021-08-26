ice_ele_attack_v2_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function ice_ele_attack_v2_modifier:IsHidden()
	return true
end

function ice_ele_attack_v2_modifier:IsDebuff()
	return false
end

function ice_ele_attack_v2_modifier:IsStunDebuff()
	return false
end

function ice_ele_attack_v2_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function ice_ele_attack_v2_modifier:OnCreated( kv )
    if not IsServer() then return end

	self.min_range = self:GetAbility():GetSpecialValueFor( "min_range" )
	self.max_range = self:GetAbility():GetCastRange( Vector(0,0,0), nil )
	self.range = self.max_range-self.min_range
	self.min_travel = self:GetAbility():GetSpecialValueFor( "min_travel" )
	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_travel" )
	self.travel_range = self.max_travel-self.min_travel
    self.projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
    self.proj_count = self:GetAbility():GetSpecialValueFor( "proj_count" )

	local interval = self:GetAbility():GetDuration()/self.proj_count + 0.01 -- so it only have 8 projectiles instead of 9
    self.target = Vector( kv.pos_x, kv.pos_y, 0 )
	self:SetValidTarget( Vector( kv.pos_x, kv.pos_y, 0 ) )
	local projectile_name = "particles/tinker/ice_bot_snapfire_lizard_blobs_arced.vpcf"
	self.num_proj = 0

	-- precache projectile
	self.info = {
		-- Target = target,
		Source = self:GetCaster(),
		Ability = self:GetAbility(),

		EffectName = projectile_name,
		iMoveSpeed = self.projectile_speed,
		bDodgeable = false,                           -- Optional

		vSourceLoc = self:GetCaster():GetOrigin(),                -- Optional (HOW)

        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

		bDrawsOnMinimap = false,                          -- Optional
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,                              -- Optional
		iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional

	}

	-- Start interval
	self:StartIntervalThink( interval )
	self:OnIntervalThink()
end

function ice_ele_attack_v2_modifier:OnRefresh( kv )
end

function ice_ele_attack_v2_modifier:OnRemoved()
end

function ice_ele_attack_v2_modifier:OnDestroy()
	if IsServer() then

	end
end

--------------------------------------------------------------------------------

-- Interval Effects
function ice_ele_attack_v2_modifier:OnIntervalThink()

	if self.num_proj < self.proj_count then 
		local vector = Clamp(self:GetParent():GetOrigin(), self.target , self:GetAbility():GetCastRange(Vector(0,0,0), nil), 0)
		self:SetValidTarget( vector )

		-- create target thinker
		local thinker = CreateModifierThinker(
			self:GetParent(), -- player source
			self:GetAbility(), -- ability source
			"circle_target_iceshot", -- modifier name
			{
				duration = self.travel_time,
				travel_time = self.travel_time,
			},
			self.target,
			self:GetParent():GetTeamNumber(),
			false
		)

		-- set projectile
		self.info.iMoveSpeed = self.vector:Length2D()/self.travel_time
		self.info.Target = thinker

		-- launch projectile
		ProjectileManager:CreateTrackingProjectile( self.info )

		-- play sound
        EmitSoundOn( "Hero_Tusk.IceShards.Cast", self:GetParent() )
		self.num_proj = self.num_proj + 1
	end

end

--------------------------------------------------------------------------------
-- Helper
function ice_ele_attack_v2_modifier:SetValidTarget( location )
	local origin = self:GetParent():GetOrigin()
	local vec = location-origin
	local direction = vec
	direction.z = 0
	direction = direction:Normalized()

	if vec:Length2D()<self.min_range then
		vec = direction * self.min_range
	elseif vec:Length2D()>self.max_range then
		vec = direction * self.max_range
	end

	self.target = GetGroundPosition( origin + vec, nil )
	self.vector = vec
	self.travel_time = (vec:Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
end