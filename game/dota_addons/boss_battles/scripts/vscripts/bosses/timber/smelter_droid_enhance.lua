smelter_droid_enhance = class({})
LinkLuaModifier( "smelter_droid_enhance_modifier", "bosses/timber/smelter_droid_enhance_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function smelter_droid_enhance:OnSpellStart()
    -- init
    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()

    -- kv reference
    local duration = 5
    local radius = 500

    -- find enemies
	local friendlies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		origin,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
    )
    
    -- find friendly boss
    for _, friend in pairs(friendlies) do
		-- check if already hit
        if friend:GetName()  == "npc_dota_hero_rubick" then
            -- create modifier
            friend:AddNewModifier(caster, self, "smelter_droid_enhance_modifier", {duration = duration})
        end
    end

    -- sound effect 
    self.sound_cast = "Hero_Lion.ManaDrain"
	EmitSoundOn( self.sound_cast, caster )

end
--------------------------------------------------------------------------------

function smelter_droid_enhance:OnChannelFinish( bInterrupted )
	-- destroy all modifier
	for modifier,_ in pairs(self.modifiers) do
		if not modifier:IsNull() then
			modifier.forceDestroy = bInterrupted
			modifier:Destroy()
		end
	end
	self.modifiers = {}

	-- end sound
	StopSoundOn( self.sound_cast, self:GetCaster() )
end
--------------------------------------------------------------------------------

function smelter_droid_enhance:Unregister( modifier )
	-- unregister modifier
	self.modifiers[modifier] = nil
end