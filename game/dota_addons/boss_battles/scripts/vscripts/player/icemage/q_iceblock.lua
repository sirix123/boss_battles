q_iceblock = class({})
LinkLuaModifier("q_iceblock_modifier", "player/icemage/modifiers/q_iceblock_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bonechill_modifier", "player/icemage/modifiers/bonechill_modifier", LUA_MODIFIER_MOTION_NONE)

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
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        local target = self:GetCursorTarget()

        self.modifier = target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "q_iceblock_modifier", -- modifier name
            { duration = duration } -- kv
        )

        if self.caster:FindModifierByNameAndCaster("bonechill_modifier", self.caster) then

            self.caster:RemoveModifierByNameAndCaster("bonechill_modifier", self.caster)

            target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "bonechill_modifier", -- modifier name
                { duration = duration } -- kv
            )

        end

        self:PlayEffects(target)

        -- swap abilities to end iceblock
        local end_ability = self.caster:FindAbilityByName("cancel_iceblock")
        if not end_ability then
		    end_ability = self.caster:AddAbility( "cancel_iceblock" )
		    self.add = end_ability
        end

	    end_ability:SetLevel( 1 )
	    end_ability.parent = self

	    -- set layout
        self:SetLayout( false )

	end
end
----------------------------------------------------------------------------------------------------------------

function q_iceblock:SetLayout(main)
	if self.layout_main~=main then
		local ability_main = "q_iceblock"
		local ability_sub = "cancel_iceblock"

		-- swap
		self:GetCaster():SwapAbilities( ability_main, ability_sub, main, (not main) )
		self.layout_main = main
	end
end
----------------------------------------------------------------------------------------------------------------
function q_iceblock:CancelIceblock( forced )
	-- remove modifier
	if forced then
		self.modifier:Destroy()
	end
	self.modifier = nil

	-- reset layout
	self:SetLayout( true )

	-- remove ability if stolen
	if self.add then
		self:GetCaster():RemoveAbility( "cancel_iceblock" )
	end
end
----------------------------------------------------------------------------------------------------------------

function q_iceblock:OnOwnerDied()

    self:CancelIceblock( true )
    
end
----------------------------------------------------------------------------------------------------------------

-- Helper Ability
cancel_iceblock = class({})
function cancel_iceblock:OnSpellStart()

    self.parent:CancelIceblock( true )

end
----------------------------------------------------------------------------------------------------------------

function q_iceblock:PlayEffects(target)

    -- add voiceover


    -- Create Sound
    EmitSoundOnLocationWithCaster( target:GetAbsOrigin(), sound_cast, self:GetCaster() )

end
----------------------------------------------------------------------------------------------------------------