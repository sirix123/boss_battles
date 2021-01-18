grab_player = class({})
LinkLuaModifier("grab_player_modifier", "bosses/beastmaster/grab_player_modifier", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function grab_player:OnAbilityPhaseStart()
    if IsServer() then

		self.vTargetPos = self:GetCursorTarget()
 		if self.vTargetPos == nil then
 			return false
        end

        return true

        --[[local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            400,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local random_unit = RandomInt(1, #units)

            self.target = units[random_unit]

            return true
        end]]
    end
end
---------------------------------------------------------------------------

function grab_player:OnSpellStart()
    --local target = self:GetCursorTarget()

    -- if player has a stun/something that stops movment remove it (dispell?)
    if self.vTargetPos:HasModifier("q_iceblock_modifier") then
        self.vTargetPos:RemoveModifierByName("q_iceblock_modifier")
    end

	-- sound
    self:GetCaster():EmitSound("Hero_Batrider.FlamingLasso.Cast")

    self.vTargetPos:AddNewModifier(self:GetCaster(), self, "grab_player_modifier", { duration= -1, })
end
---------------------------------------------------------------------------