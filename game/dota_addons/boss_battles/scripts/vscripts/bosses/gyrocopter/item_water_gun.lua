item_water_gun = class({})
LinkLuaModifier("water_gun_dmg_buff", "bosses/gyrocopter/water_gun_dmg_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("water_gun_dmg_debuff", "bosses/gyrocopter/water_gun_dmg_debuff", LUA_MODIFIER_MOTION_NONE)

function item_water_gun:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()

    local vTargetPos = nil
    vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    local projectile_direction = ( vTargetPos - origin ):Normalized()

    local radius = 250

    local projectile = {
        EffectName = "particles/gyrocopter/water_gun_morphling_base_attack.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", --"particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",--"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
        vSpawnOrigin = origin + projectile_direction,
        fDistance = (vTargetPos - origin):Length2D(),
        fStartRadius = radius,
        fEndRadius = radius,
        Source = caster,
        vVelocity = projectile_direction * 1000,
        UnitBehavior = PROJECTILES_NOTHING,
        bMultipleHits = false,
        TreeBehavior = PROJECTILES_NOTHING,
        WallBehavior = PROJECTILES_DESTROY,
        GroundBehavior = PROJECTILES_FOLLOW,
        fGroundOffset = 80,
        draw = false,
        UnitTest = function(_self, unit)
        end,
        OnUnitHit = function(_self, unit)
        end,
        OnWallHit = function(_self, gnvPos)
        end,
        OnFinish = function(_self, pos)

            -- find the thinkers and extingush
            local i = 0
            local previous_result = nil
            local result = nil
            while i < 8 do

                if previous_result == nil then
                    result = Entities:FindByClassnameWithin(nil, "npc_dota_thinker", pos, radius)
                else
                    result = Entities:FindByClassnameWithin(previous_result, "npc_dota_thinker", pos, radius)
                end

                if result ~= nil then
                    previous_result = result
                    if result:FindModifierByName("oil_drop_thinker") or result:FindModifierByName("oil_ignite_fire_puddle_thinker") then
                        result:RemoveSelf()

                        if i == 0 then
                            caster:AddNewModifier( caster, self, "water_gun_dmg_buff", { duration = 10 } )
                            EmitSoundOn("Hero_Shared.WaterFootsteps",caster)
                        end

                    end
                end

                i = i + 1
            end

            local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_splash_diving_helmet.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl(nFXIndex, 0, pos)
            ParticleManager:SetParticleControl(nFXIndex, 3, pos)
            ParticleManager:ReleaseParticleIndex( nFXIndex )
        end,
    }

    -- Cast projectile
    Projectiles:CreateProjectile(projectile)

    -- sound effect
    caster:EmitSound("Beastmaster_Boar.Attack")

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

function item_water_gun:GetAOERadius()
	return 250
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------