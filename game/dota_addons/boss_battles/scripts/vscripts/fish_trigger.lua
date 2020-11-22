
function fishtrigger(trigger)

        local ent = trigger.activator

        if not ent then return end

        PrintTable(trigger, indent, done)
        --particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_splash_whaleblade.vpcf

        -- some epic awesome spell animation thing being eaten by fish then frag the player

        --ent:ForceKill(true)

        ent:AddNewModifier( thisEntity, nil, "modifier_stunned", { duration = -1 } )

        local bubbles = "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
        thisEntity.bubbles = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(thisEntity.bubbles , 0, thisEntity:GetAbsOrigin())

        Timers:CreateTimer(3.0,function()
            ParticleManager:DestroyParticle(thisEntity.bubbles, true)

            EmitSoundOn("Hero_Kunkka.SharkShip.Crash", ent)

            local particle = "particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_splash_whaleblade.vpcf"
            thisEntity.head_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(thisEntity.head_particle, 0, thisEntity:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(thisEntity.head_particle)

            --[[local damageTable = {
                victim = ent,
                attacker = trigger,
                damage = 500,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
            }

            ApplyDamage(damageTable)]]

            ent:ForceKill(true)
            return false
        end)

    return 0.1
end