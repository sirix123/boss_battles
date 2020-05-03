mine_droid_laymine = class({})

LinkLuaModifier( "mine_droid_laymine_thinker", "bosses/timber/mine_droid_laymine_thinker", LUA_MODIFIER_MOTION_NONE )

function mine_droid_laymine:OnSpellStart()
    local caster = self:GetCaster()

    if self:GetCursorTarget() then
		self.point = self:GetCursorTarget():GetOrigin()
	else
		self.point = self:GetCursorPosition()
	end

    self.land_mine = CreateUnitByName("npc_dota_techies_land_mine", self.point, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

    if self.land_mine ~= nil then
        self.land_mine_thinker = CreateModifierThinker(
        caster,
        self,
        "mine_droid_laymine_thinker",
        {
            target_x = self.point.x,
            target_y = self.point.y,
            target_z = self.point.z,
        },
        self.land_mine:GetAbsOrigin(),
        caster:GetTeamNumber(),
        false)
    end

    -- might need a sound here
end