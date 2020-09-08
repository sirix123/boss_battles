cancel_ice_block = class({})

function cancel_ice_block:OnSpellStart()
    if IsServer() then

        -- init
        self.caster = self:GetCaster()

        local friendlies = FindUnitsInRadius(
            self.caster:GetTeam(),
            self.caster:GetOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false
        )

        if friendlies ~= nil then
            for _, friend in pairs(friendlies) do
                if friend:HasModifier("q_iceblock_modifier") then
                    friend:RemoveModifierByNameAndCaster("q_iceblock_modifier", self.caster)
                end
            end
        end

        self.caster:SwapAbilities("q_iceblock", "cancel_ice_block", true, false)

	end
end
----------------------------------------------------------------------------------------------------------------