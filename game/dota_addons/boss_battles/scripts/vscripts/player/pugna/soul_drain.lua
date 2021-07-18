soul_drain = class({})
LinkLuaModifier("soul_crystals", "player/pugna/modifiers/soul_crystals", LUA_MODIFIER_MOTION_NONE)

function soul_drain:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 1.0)

        self:GetCaster():FindAbilityByName("pugna_m2"):SetActivated(false)
        self:GetCaster():FindAbilityByName("pugna_basic_attack"):SetActivated(false)
        self:GetCaster():FindAbilityByName("e_magic_circle_pugna"):SetActivated(false)
        self:GetCaster():FindAbilityByName("r_infest_pugna"):SetActivated(false)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        else

            self.target = units[1]

            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = -1,
                bMovementLock = true,
                bFaceTarget = true,
                target = self.target:GetEntityIndex(),
                --bSpellLock = true,
            })

            return true
        end
    end
end
---------------------------------------------------------------------------

function soul_drain:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

    end
end
---------------------------------------------------------------------------

function soul_drain:OnSpellStart()
    if IsServer() then

        -- init
        self.caster = self:GetCaster()

        local mana = self:GetSpecialValueFor( "mana" )
        local dmg = self:GetSpecialValueFor( "dmg" )
        local drain_tick_rate = self:GetSpecialValueFor( "drain_tick_rate" )
        local max_ticks = self:GetSpecialValueFor( "max_ticks" )
        local duration_buff_soul_crystal = self:GetSpecialValueFor( "duration_buff_soul_crystal" )

        -- attach particle lifedrain to target and pugna
        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetOrigin(), true )

        self:GetCaster():EmitSound("Hero_Pugna.LifeDrain.Cast")
        self.target:EmitSound("Hero_Pugna.LifeDrain.Loop")

        local i = 1
        Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then
                if self:GetCaster():HasModifier("casting_modifier_thinker") then
                    self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
                end
                if nFXIndex then
                    ParticleManager:DestroyParticle(nFXIndex,false)
                end

                self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

                self.target:StopSound("Hero_Pugna.LifeDrain.Loop")

                self:CleanUp()

                return false
            end

            if self.caster:IsAlive() == false or self.target:IsAlive() == false then
                if self:GetCaster():HasModifier("casting_modifier_thinker") then
                    self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
                end
                if nFXIndex then
                    ParticleManager:DestroyParticle(nFXIndex,false)
                end

                self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

                self.target:StopSound("Hero_Pugna.LifeDrain.Loop")

                self:CleanUp()

                return false
            end

            if i == max_ticks then

                local dmgTable = {
                    victim = self.target,
                    attacker = self:GetCaster(),
                    damage = dmg,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                -- give mana
                self:GetCaster():ManaOnHit(mana)

                ApplyDamage(dmgTable)

                -- give soul crystal
                self:GetCaster():AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "soul_crystals", -- modifier name
                    {
                        duration = duration_buff_soul_crystal,
                    } -- kv
                )

                -- makes stacks drop off individually
                Timers:CreateTimer(duration_buff_soul_crystal, function()

                    if self:GetCaster():HasModifier("soul_crystals") then
                        local stacks = self:GetCaster():GetModifierStackCount("soul_crystals", self:GetCaster())
                        if stacks > 0 then
                            self:GetCaster():SetModifierStackCount("soul_crystals", self:GetCaster(), stacks -1)
                        end
                    end

                    return false
                end)

                if self:GetCaster():HasModifier("casting_modifier_thinker") then
                    self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
                end
                if nFXIndex then
                    ParticleManager:DestroyParticle(nFXIndex,false)
                end

                self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)

                self.target:StopSound("Hero_Pugna.LifeDrain.Loop")

                self:CleanUp()

                return false
            end

            -- do dmg
            -- give mana

            local dmgTable = {
                victim = self.target,
                attacker = self:GetCaster(),
                damage = dmg,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            -- give mana
            self:GetCaster():ManaOnHit(mana)

            ApplyDamage(dmgTable)

            i = i + 1
            return drain_tick_rate
        end)
	end
end
----------------------------------------------------------------------------------------------------------------

function soul_drain:CleanUp()
    if IsServer() then
        self:GetCaster():FindAbilityByName("pugna_m2"):SetActivated(true)
        self:GetCaster():FindAbilityByName("pugna_basic_attack"):SetActivated(true)
        self:GetCaster():FindAbilityByName("e_magic_circle_pugna"):SetActivated(true)
        self:GetCaster():FindAbilityByName("r_infest_pugna"):SetActivated(true)
    end
end