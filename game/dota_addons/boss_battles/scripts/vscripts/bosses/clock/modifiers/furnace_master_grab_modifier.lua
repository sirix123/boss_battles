furnace_master_grab_modifier = class({})

--------------------------------------------------------------------------------

function furnace_master_grab_modifier:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function furnace_master_grab_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function furnace_master_grab_modifier:OnCreated( kv )
	if IsServer() then
		self.grab_radius = self:GetAbility():GetSpecialValueFor( "grab_radius" ) --200
		self.min_hold_time = self:GetAbility():GetSpecialValueFor( "min_hold_time" ) -- 3
		self.max_hold_time = self:GetAbility():GetSpecialValueFor( "max_hold_time" ) --5
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function furnace_master_grab_modifier:OnIntervalThink()
	if IsServer() then
        if self.hTarget == nil then
			return
        end

		local flDist = ( self.hTarget:GetOrigin() - self:GetParent():GetOrigin() ):Length2D()
        if flDist > 700 then
			return
		end

		local hBuff = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "furnace_master_grabbed_buff", {} )
		if hBuff ~= nil then
			self:GetCaster().flThrowTimer = GameRules:GetGameTime() + RandomFloat( self.min_hold_time, self.max_hold_time )
			hBuff.hThrowObject = self.hTarget
            self.hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "furnace_master_grab_debuff", {} )
		end
		self:Destroy()
		return
	end
end