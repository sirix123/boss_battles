r_explosive_arrow_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function r_explosive_arrow_modifier:IsHidden()
	return false
end

function r_explosive_arrow_modifier:IsDebuff()
	return false
end

function r_explosive_arrow_modifier:IsStunDebuff()
	return false
end

function r_explosive_arrow_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function r_explosive_arrow_modifier:OnCreated( kv )
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
	self:SetValidTarget( Vector( kv.pos_x, kv.pos_y, 0 ) )
	local projectile_name = "particles/ranger/ranger_snapfire_lizard_blobs_arced.vpcf"

	-- precache projectile
	self.info = {
		-- Target = target,
		Source = self:GetCaster(),
		Ability = self:GetAbility(),

		EffectName = projectile_name,
		iMoveSpeed = self.projectile_speed,
		bDodgeable = false,                           -- Optional

		vSourceLoc = self:GetCaster():GetOrigin(),                -- Optional (HOW)

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

function r_explosive_arrow_modifier:OnRefresh( kv )
end

function r_explosive_arrow_modifier:OnRemoved()
end

function r_explosive_arrow_modifier:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function r_explosive_arrow_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}

	return funcs
end

function r_explosive_arrow_modifier:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	-- stop or hold
	if
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
        self:Destroy()
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
	end
end
--------------------------------------------------------------------------------

-- Interval Effects
function r_explosive_arrow_modifier:OnIntervalThink()

    -- if we want turn rate limit, measure the 2d length to the mouse point to get the cast  range then use the beam formulae ... forward vector * mousedistance * origin
    local vector = Clamp(self:GetParent():GetOrigin(), Vector(self:GetParent().mouse.x, self:GetParent().mouse.y, self:GetParent().mouse.z), self:GetAbility():GetCastRange(Vector(0,0,0), nil), 0)
    self:SetValidTarget( vector )

	-- create target thinker
	local thinker = CreateModifierThinker(
		self:GetParent(), -- player source
		self:GetAbility(), -- ability source
		"r_explosive_arrow_thinker_indicator", -- modifier name
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
	local sound_cast = "Hero_Snapfire.MortimerBlob.Launch"
	EmitSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Helper
function r_explosive_arrow_modifier:SetValidTarget( location )
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