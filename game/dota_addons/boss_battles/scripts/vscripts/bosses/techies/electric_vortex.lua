electric_vortex = class({})
LinkLuaModifier( "modifier_electric_vortex", "bosses/techies/modifiers/modifier_electric_vortex", LUA_MODIFIER_MOTION_HORIZONTAL )

function electric_vortex:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = nil

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- find targets
    local targets = FindUnitsInRadius(
        caster:GetTeamNumber(),	-- int, your team number
        caster:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    if targets ~= nil and targets ~= 0 then
        targets[RandomInt(1, #targets)]:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_electric_vortex", -- modifier name
            {
                duration = duration,
                x = caster:GetOrigin().x,
                y = caster:GetOrigin().y,
            } -- kv
        )
    end

	-- play effects
	local sound_cast = "Hero_StormSpirit.ElectricVortexCast"
	EmitSoundOn( sound_cast, caster )
end