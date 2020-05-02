smelter_droid_enhance = class({})
LinkLuaModifier( "smelter_droid_enhance_modifier_thinker", "bosses/timber/smelter_droid_enhance_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "smelter_droid_enhance_modifier", "bosses/timber/smelter_droid_enhance_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

smelter_droid_enhance.modifiers = {}
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
        if friend:GetName()  == "npc_dota_hero_shredder" then
            -- create modifier
            self.modifier = friend:AddNewModifier(caster, self, "smelter_droid_enhance_modifier_thinker", {duration = duration})
        end
	end

	self.modifiers[self.modifier] = true

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

	-- check if there are no modifier left
	local counter = 0
	for modifier,_ in pairs(self.modifiers) do
		if not modifier:IsNull() then
			counter = counter+1
		end
	end

	-- stop channelling if no other target exist
	if counter==0 and self:IsChanneling() then
		self:EndChannel( false )
	end
end