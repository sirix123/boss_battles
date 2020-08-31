space_roar = class({})

LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

function space_roar:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_FLAIL, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function space_roar:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_FLAIL)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_roar:OnSpellStart()
    if IsServer() then

        -- remove casting animation
        --self:GetCaster():RemoveGesture(ACT_DOTA_FLAIL)

        local caster = self:GetCaster()

        self.tMainAbilities =
        {
            "m1_trackingshot",
            "m2_serratedarrow",
            "q_herbarrow",
            "e_syncwithforest",
            "r_metamorph",
            "space_roar"
        }

        -- references
        local distance = self:GetSpecialValueFor( "distance" ) -- special value
        local speed = self:GetSpecialValueFor( "speed" ) -- special value
        local height = self:GetSpecialValueFor( "height" )

        -- leap
        local arc = caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                distance = distance,
                speed = speed,
                height = height,
                fix_end = false,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            self:GetCaster():RemoveGesture(ACT_DOTA_FLAIL)

            -- enable when arc ends
            for i = 1 , #self.tMainAbilities, 1 do
                local abilityToEnable = caster:FindAbilityByName(self.tMainAbilities[i])
                abilityToEnable:SetActivated( true )
            end
        end)

        -- disable
        for i = 1 , #self.tMainAbilities, 1 do
            local abilityToDisable = caster:FindAbilityByName(self.tMainAbilities[i])
            abilityToDisable:SetActivated( false )
        end

    end
end