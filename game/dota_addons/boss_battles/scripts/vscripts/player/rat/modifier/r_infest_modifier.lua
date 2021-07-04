r_infest_modifier = class({})

-----------------------------------------------------------------------------
-- Classifications
function r_infest_modifier:IsHidden()
	return false
end

function r_infest_modifier:IsDebuff()
	return false
end

function r_infest_modifier:GetTexture()
	return "queenofpain_blink"
end

function r_infest_modifier:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf"
end

function r_infest_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_goo.vpcf"
end
-----------------------------------------------------------------------------

function r_infest_modifier:OnCreated( kv )
	if not IsServer() then return end

    self.total_damage = 0
    self.dot_duration = kv.dot_duration

end

function r_infest_modifier:OnRefresh( kv )
	if not IsServer() then return end

	self:OnCreated()

end

function r_infest_modifier:OnRemoved()
    if not IsServer() then return end

end

function r_infest_modifier:OnDestroy()
	if not IsServer() then return end

    self:GetParent():AddNewModifier(
        self:GetCaster(), -- player source
        self:GetAbility(), -- ability source
        "r_infest_modifier_damage", -- modifier name
        {
            duration = self.dot_duration,
            dmg = self.total_damage,
        } -- kv
    )

end
----------------------------------------------------------------------------

function r_infest_modifier:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function r_infest_modifier:OnTakeDamage( params )
    if IsServer() then
        --print("params.attacker.name ",params.attacker:GetUnitName())
        if params.attacker:GetUnitName() == "npc_dota_hero_hoodwink" then
            --print("healing")
            --print("original_damage ",params.original_damage)
            --print("damage ",params.damage)

            local damage = params.damage
            self.total_damage = damage + self.total_damage

            --print("self.total_damage ",self.total_damage)

        end
    end
end

