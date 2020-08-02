furnace_master_grab_throw = class({})
LinkLuaModifier( "furnace_master_grab_modifier", "bosses/clock/modifiers/furnace_master_grab_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "furnace_master_grabbed_buff", "bosses/clock/modifiers/furnace_master_grabbed_buff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "furnace_master_grab_debuff", "bosses/clock/modifiers/furnace_master_grab_debuff", LUA_MODIFIER_MOTION_BOTH )

----------------------------------------------------------------------------------------

function furnace_master_grab_throw:Precache( context )

	--PrecacheResource( "particle", "particles/test_particle/generic_attack_crit_blur.vpcf", context )

end

--------------------------------------------------------------------------------

function furnace_master_grab_throw:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function furnace_master_grab_throw:OnAbilityPhaseStart()
	if IsServer() then
		if self:GetCaster():FindModifierByName( "furnace_master_grabbed_buff" ) ~= nil then
			return false
		end

        local duration = 1
		local hBuff = self:GetCaster():AddNewModifier( self:GetCaster(), self, "furnace_master_grab_modifier", { duration = duration } )
        if hBuff ~= nil then
            hBuff.hTarget = self:GetCursorTarget()
		end

		-- effect and sound
		
	end
	return true
end

--------------------------------------------------------------------------------

function furnace_master_grab_throw:OnAbilityPhaseInterrupted()
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "furnace_master_grab_modifier" )
	end
end
--------------------------------------------------------------------------------

function furnace_master_grab_throw:GetCastRange( vLocation, hTarget )
	if IsServer() then
		if self:GetCaster():FindModifierByName( "furnace_master_grab_modifier" ) ~= nil then
			return 99999
		end
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end