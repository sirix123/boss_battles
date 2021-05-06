cleaning_bot_ai = class({})
LinkLuaModifier( "oil_fire_checker_modifier", "bosses/gyrocopter/oil_fire_checker_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 })

	thisEntity:SetHullRadius(80)

    thisEntity.STATE = 1

    thisEntity.moving = false

    thisEntity:SetContextThink( "CleaningThinker", CleaningThinker, 0.1 )

end
--------------------------------------------------------------------------------

function CleaningThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    -- state checker for klat state
    if thisEntity:HasModifier("oil_fire_checker_modifier") then
        thisEntity.stack_count = thisEntity:GetModifierStackCount("oil_fire_checker_modifier", nil)
        print("thisEntity.stack_count ",thisEntity.stack_count)
        if thisEntity.stack_count >= 10 then
            thisEntity.STATE = 4
        end
    end

    -- state 1
    -- find oil puddles or fire puddles
    if thisEntity.STATE == 1 then
        print("phase 1")

        if #_G.Oil_Puddles ~= 0 or #_G.Fire_Puddles ~= 0 then
            if #_G.Oil_Puddles ~= 0 then
                local randomIndex = RandomInt(1,#_G.Oil_Puddles)
                thisEntity.puddle = _G.Oil_Puddles[randomIndex]
                if IsValidEntity(thisEntity.puddle) then
                    thisEntity.puddle_location = _G.Oil_Puddles[randomIndex]:GetAbsOrigin()
                    thisEntity.STATE = 2
                end
            elseif #_G.Fire_Puddles ~= 0 then
                local randomIndex = RandomInt(1,#_G.Fire_Puddles)
                thisEntity.puddle = _G.Fire_Puddles[randomIndex]
                if IsValidEntity(thisEntity.puddle) then
                    thisEntity.puddle_location = _G.Fire_Puddles[randomIndex]:GetAbsOrigin()
                    thisEntity.STATE = 2
                end
            else
                return 1
            end
        end

        return 1
    end

    -- state 2
    -- move towards the puddle
    if thisEntity.STATE == 2 then
        print("phase 2")
        if thisEntity.moving == false then
            thisEntity:MoveToPosition(thisEntity.puddle_location)
        end

        local distance = ( thisEntity:GetAbsOrigin() - thisEntity.puddle_location ):Length2D()
        if distance < 10 then
            thisEntity.moving = true
            thisEntity.STATE = 3
        end

        return 0.5
    end

    -- state 3
    -- channel over the puddle for 1 second
    if thisEntity.STATE == 3 then
        print("phase 3")
        thisEntity.moving = false

        -- water effect
        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_splash_diving_helmet.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl(nFXIndex, 0, thisEntity.puddle_location)
        ParticleManager:SetParticleControl(nFXIndex, 3, thisEntity.puddle_location)
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        if IsValidEntity(thisEntity.puddle) then
            thisEntity.puddle:RemoveSelf()
            thisEntity:AddNewModifier( nil, thisEntity, "oil_fire_checker_modifier", { duration = -1 })
        end

        thisEntity.STATE = 1

        return 1
    end

    -- state 5
    -- if at max puddle stacks
    -- spawn a target indicator around self (green)
    -- explode after 15 seconds
    -- if no enemies come close to me (inside the green indicator) then inflict dmg on all enemies, if someone is close just hurt them (kill them) if they have the buff don't kill them
    if thisEntity.STATE == 4 then
        print("phase 4")

        thisEntity.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/custom/markercircle/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 0, thisEntity:GetAbsOrigin() )
        ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 1, Vector( 250, -250, -250 ) )
        ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 2, Vector( 15, 0, 0 ) );
        ParticleManager:ReleaseParticleIndex(thisEntity.nPreviewFXIndex)

        Timers:CreateTimer(10, function()
            if IsValidEntity(thisEntity) == false then
                return false
            end

            EmitSoundOn("Hero_ObsidianDestroyer.SanityEclipse.Cast", thisEntity)

            local particle_area_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_WORLDORIGIN, thisEntity)
            ParticleManager:SetParticleControl(particle_area_fx, 0, thisEntity:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_area_fx, 1, Vector(250, 1, 1))
            ParticleManager:SetParticleControl(particle_area_fx, 2, Vector(250, 1, 1))
            ParticleManager:SetParticleControl(particle_area_fx, 3, thisEntity:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_area_fx)

            local enemies = FindUnitsInRadius(
                thisEntity:GetTeamNumber(),	-- int, your team number
                thisEntity:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                250,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO,	-- int, type filter
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                FIND_CLOSEST,	-- int, order filter
                false	-- bool, can grow cache
            )

            if enemies ~= nil and #enemies ~= 0 then

                local particle_burn_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_mana_loss.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
                ParticleManager:SetParticleControl(particle_burn_fx, 0, enemies[1]:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle_burn_fx)

                local dmgTable = {
                    victim = enemies[1],
                    attacker = thisEntity,
                    damage = 300,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                }

                ApplyDamage(dmgTable)
            end

            if enemies == nil or #enemies == 0 then

                local enemies_everywhere = FindUnitsInRadius(
                    thisEntity:GetTeamNumber(),	-- int, your team number
                    thisEntity:GetAbsOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO,	-- int, type filter
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                    FIND_CLOSEST,	-- int, order filter
                    false	-- bool, can grow cache
                    )


                if enemies_everywhere ~= nil and #enemies_everywhere ~= 0 then
                    for _, enemy in pairs(enemies_everywhere) do

                        local particle_burn_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_mana_loss.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
                        ParticleManager:SetParticleControl(particle_burn_fx, 0, enemy:GetAbsOrigin())
                        ParticleManager:ReleaseParticleIndex(particle_burn_fx)

                        local dmgTable = {
                            victim = enemy,
                            attacker = thisEntity,
                            damage = 300,
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                        }

                        ApplyDamage(dmgTable)
                    end
                end
            end

            thisEntity:ForceKill(false)

            return false
        end)

        return 16
    end

	return 0.5
end
--------------------------------------------------------------------------------