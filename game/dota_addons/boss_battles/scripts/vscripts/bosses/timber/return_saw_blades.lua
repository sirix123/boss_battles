return_saw_blades = class({})

LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )

function return_saw_blades:OnSpellStart()
    if IsServer() then

        self.caster = self:GetCaster()

        for _, v in pairs( _G.tSummonedSawBlades ) do
            if v and not v:IsNull() then
                v:ReturnChakram()
            end
        end

        _G.tSummonedSawBlades = {}

        -- level up saw blades
        local hSpell =  self.caster:FindAbilityByName("saw_blade")
        local currentSpellLevel = hSpell:GetLevel()

        local newLevel = currentSpellLevel + 1
        hSpell:SetLevel(newLevel)
    end
end