
function fishtrigger(trigger)

        local ent = trigger.activator

        if not ent then return end

        --PrintTable(trigger, indent, done)
        --particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_splash_whaleblade.vpcf

        -- some epic awesome spell animation thing being eaten by fish then frag the player

        --ent:ForceKill(true)

        local units = FindUnitsInRadius(
        ent:GetTeamNumber(),	-- int, your team number
        ent:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_ALL,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
        )

        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_beastmaster" then
                thisEntity.ability = unit:FindAbilityByName("fish_puddle")
                thisEntity.unit = unit
            end
        end


        ent:AddNewModifier( thisEntity, nil, "modifier_stunned", { duration = -1 } )
        ent:AddNewModifier( ent, nil, "modifier_invulnerable", { duration = -1 } )

        local bubbles = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
        thisEntity.bubbles = ParticleManager:CreateParticle(bubbles, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(thisEntity.bubbles , 0, ent:GetAbsOrigin())

        Timers:CreateTimer(3.0,function()
            ParticleManager:DestroyParticle(thisEntity.bubbles, true)

            EmitSoundOn("Hero_Kunkka.SharkShip.Crash", ent)

            local particle = "particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_splash_whaleblade.vpcf"
            thisEntity.head_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(thisEntity.head_particle, 0, ent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(thisEntity.head_particle)

            --[[local damageTable = {
                victim = ent,
                attacker = trigger,
                damage = 500,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
            }

            ApplyDamage(damageTable)]]
            -- Kill(ability: CDOTABaseAbility | nil, attacker: CDOTA_BaseNPC | nil): nil
            if thisEntity.ability and thisEntity.unit then
                ent:Kill(thisEntity.ability,thisEntity.unit)
            end

            --ent:ForceKill(true)
            return false
        end)

    return 0.1
end