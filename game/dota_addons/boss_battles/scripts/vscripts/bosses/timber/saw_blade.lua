--[[

    This script needs to handle the following: 
        Initial cast location 
        Handle thinkers


]]
LinkLuaModifier( "saw_blade_thinker", "bosses/timber/saw_blade_thinker", LUA_MODIFIER_MOTION_NONE )

_G.tSummonedSawBlades = {  }

saw_blade = class({})

function saw_blade:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1.0)

        local vNewPositionX = RandomInt(8622, 11550)
        local vNewPositionY = RandomInt(-11882, -8910)
        self.point = Vector(vNewPositionX, vNewPositionY, 131)

        self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl(self.nFXIndex, 0, self.point)
		ParticleManager:ReleaseParticleIndex( self.nFXIndex )

        return true
    end
end

function saw_blade:OnSpellStart()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_SPAWN)

        ParticleManager:DestroyParticle(self.nFXIndex, false)

        self.caster = self:GetCaster()
        --local point = self:GetCursorPosition() --self.point

        -- ref kv
        self.nMaxSawBlades = self:GetSpecialValueFor("nMaxSawBlades")

        -- play random sound effect on cast
        local tSoundEffects =
        {
            "shredder_timb_attack_03",
            "shredder_timb_attack_04",
            "shredder_timb_attack_06",
        }

        EmitSoundOn(tSoundEffects[ RandomInt( 1, #tSoundEffects ) ], self.caster)

        --print("#_G.tSummonedSawBlades: ",#_G.tSummonedSawBlades, " self.nMaxSawBlades: ", self.nMaxSawBlades )
        if #_G.tSummonedSawBlades < self.nMaxSawBlades then
            self.caster = CreateModifierThinker(
                self.caster,
                self,
                "saw_blade_thinker",
                {
                    target_x = self.point.x,
                    target_y = self.point.y,
                    target_z = self.point.z,
                },
                self.point,
                --self.caster:GetAbsOrigin(),
                self.caster:GetTeamNumber(),
                false
            )

            local sound_cast = "Hero_Shredder.Chakram.Cast"
            EmitSoundOn( sound_cast, self.caster )
        end

        table.insert(_G.tSummonedSawBlades,  self.caster:FindModifierByName( "saw_blade_thinker" ))

    end
end
--------------------------------------------------------------------------------
