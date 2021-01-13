q_meditate = class({})
LinkLuaModifier( "q_meditate_modifier", "player/warlord/modifiers/q_meditate_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_meditate:OnSpellStart()
    if IsServer() then

        --print("does this print once or lots")

        if self:GetCaster():HasModifier("m2_sword_slam_buff") then
            self:GetCaster():RemoveModifierByName("m2_sword_slam_buff")
        end

        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )

        caster:FindAbilityByName("m1_sword_slash"):SetActivated(false)
        caster:FindAbilityByName("m2_sword_slam"):SetActivated(false)
        --caster:FindAbilityByName("q_meditate"):SetActivated(false)
        caster:FindAbilityByName("e_spawn_ward"):SetActivated(false)
        caster:FindAbilityByName("r_sword_slam"):SetActivated(false)
        caster:FindAbilityByName("space_chain_hook"):SetActivated(false)

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "q_meditate_modifier", -- modifier name
            { duration = duration} -- kv
        )

    end
end

function q_meditate:OnChannelFinish( bInterrupted )
	if self.modifier then
		self.modifier:Destroy()

		if self:IsChanneling() then
			self:GetParent():Stop()
		end
	end
end