q_iceblock = class({})
LinkLuaModifier("q_iceblock_modifier", "player/icemage/modifiers/q_iceblock_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("q_iceblock_modifier_thinker", "player/icemage/modifiers/q_iceblock_modifier_thinker", LUA_MODIFIER_MOTION_NONE)

function q_iceblock:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function q_iceblock:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_iceblock:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        local caster = self:GetCaster()
        local duration = 5

        -- target
        -- this is a really bad implementation tbh... edge cases? phasing players... somehow closely packed players...
        -- ALSO? IF ITS NOT A TARGET IT GOES ON CD? need logic in interupt?
            -- add that code to onabilityphase start?
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[caster:GetPlayerID()]
        local target = self:GetCursorTarget()

        --[[local friendly = FindUnitsInRadius(
            DOTA_TEAM_GOODGUYS,
            vTargetPos,
            nil,
            50,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )
        
        if #friendly ~= 0 and friendly ~= nil then
            friendly[1]:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "q_iceblock_modifier", -- modifier name
                { duration = duration } -- kv
            )
        end]]

        target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "q_iceblock_modifier", -- modifier name
            { duration = duration } -- kv
        )


        --DebugDrawCircle(vTargetPos, Vector(0,0,255), 128, 10, true, 60)
	end
end
----------------------------------------------------------------------------------------------------------------
