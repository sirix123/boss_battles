if Wearables == nil then
    Wearables = class({})
end

LinkLuaModifier( "modifier_arcana_cosmetics", "player/generic/modifier_arcana_cosmetics", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "companion_modifier", "core/companion_modifier", LUA_MODIFIER_MOTION_NONE )

function Wearables:MapWearablesToProductlist( product_list )

    self.wearable_table = {}

    for _, product in pairs(product_list) do
        for _, product_id in pairs(product.products) do
            local wearable = {}

            if product_id == "prod_JeM6EdQsCCvQbB" then
                wearable["product_id"] = product_id

                self.model = "models/heroes/crystal_maiden/crystal_maiden_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["weapon"] = "models/items/crystal_maiden/cm_ti9_immortal_weapon/cm_ti9_immortal_weapon.vmdl"
                wearable["equipment"]["back"] = "models/heroes/crystal_maiden/crystal_maiden_arcana_back.vmdl"

                wearable["portrait"] = "npc_dota_hero_crystal_maiden_alt1"

                wearable["particle_weapon_1"] = {}
                wearable["particle_weapon_1"]["particle_settings"] = {}
                wearable["particle_weapon_1"]["particle_settings"]["particle_string"] = "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_staff_ambient.vpcf"
                wearable["particle_weapon_1"]["particle_settings"]["particle_attach_loc"] = "attach_attack1"

                self.pet = "npc_cm_cosmetic_pet"
                wearable["pet"] = self.pet

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "prod_JhhDzGDJJb9t1z" then
                wearable["product_id"] = product_id

                self.model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["armor"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_armor.vmdl"
                wearable["equipment"]["weapon"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_dagger.vmdl"
                wearable["equipment"]["hair"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl"
                wearable["equipment"]["wings"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_wings.vmdl"

                wearable["portrait"] = "npc_dota_hero_queenofpain_alt1"

                wearable["particle_weapon_1"] = {}
                wearable["particle_weapon_1"]["particle_settings"] = {}
                wearable["particle_weapon_1"]["particle_settings"]["particle_string"] = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blade_ambient.vpcf"
                wearable["particle_weapon_1"]["particle_settings"]["particle_attach_loc"] = "attach_attack1"

                wearable["particle_weapon_2"] = {}
                wearable["particle_weapon_2"]["particle_settings"] = {}
                wearable["particle_weapon_2"]["particle_settings"]["particle_string"] = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_whip_ambient.vpcf"
                wearable["particle_weapon_2"]["particle_settings"]["particle_attach_loc"] = "attach_whip_end"

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "prod_JhhDjvKw86l9bm" then
                wearable["product_id"] = product_id

                self.model = "models/heroes/phantom_assassin/pa_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["head"] = "models/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_head.vmdl"
                wearable["equipment"]["weapon"] = "models/heroes/phantom_assassin/pa_arcana_weapons.vmdl"
                wearable["equipment"]["shoulders"] = "models/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_immortal_shoulders.vmdl"

                wearable["portrait"] = "npc_dota_hero_phantom_assassin_alt1"

                wearable["particle_weapon_1"] = {}
                wearable["particle_weapon_1"]["particle_settings"] = {}
                wearable["particle_weapon_1"]["particle_settings"]["particle_string"] = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_a.vpcf"
                wearable["particle_weapon_1"]["particle_settings"]["particle_attach_loc"] = "attach_attack1"

                wearable["particle_weapon_2"] = {}
                wearable["particle_weapon_2"]["particle_settings"] = {}
                wearable["particle_weapon_2"]["particle_settings"]["particle_string"] = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_b.vpcf"
                wearable["particle_weapon_2"]["particle_settings"]["particle_attach_loc"] = "attach_attack2"

                wearable["modifier_arcana"] = "modifier_arcana_cosmetics"

                table.insert(self.wearable_table,wearable)
            end

        end
    end
end

function Wearables:FindWearables( product_id )

    if self.wearable_table then
        for _, value in pairs(self.wearable_table) do
            if product_id == value.product_id then
                return value
            end
        end
    end
end

function Wearables:EquipWearables( product_id , hero )

    local wearables_for_hero = Wearables:FindWearables( product_id )
    local equipment = nil

    if wearables_for_hero then

        -- set a flag on the hero to set the wearable to true... (can use this to change animations etc assuming these is only one arcana per hero pretty easy)
        -- also easier to set custom particles for the arcana for spells
        hero.arcana_equipped = true

        if wearables_for_hero.modifier_arcana then
            hero:AddNewModifier( hero, nil, wearables_for_hero.modifier_arcana, { duration = -1 } )
        end

        -- change the hero model if there is one...
        if wearables_for_hero.model then
            hero:SetModel(wearables_for_hero.model)
            hero:SetOriginalModel(wearables_for_hero.model)
        end

        -- change the equipment wearable models if there are any
        if wearables_for_hero.equipment then
            for _, model in pairs(wearables_for_hero.equipment) do
                equipment = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model})
                equipment:FollowEntity(hero, true)
            end
        end

        -- attach particle effect to weapon wep 1 / main weap)
        if wearables_for_hero.particle_weapon_1 then
            for _, particle in pairs(wearables_for_hero.particle_weapon_1) do
                local effect_cast = ParticleManager:CreateParticle( particle.particle_string, PATTACH_ABSORIGIN_FOLLOW, hero )

                ParticleManager:SetParticleControlEnt(
                    effect_cast,
                    0,
                    hero,
                    PATTACH_POINT_FOLLOW,
                    particle.particle_attach_loc,
                    Vector(0,0,0),
                    true
                )

                if string.find(particle.particle_string, "phantom_assassin" ) then
                    ParticleManager:SetParticleControl(effect_cast, 9, Vector(-100, 0, 0))
                    ParticleManager:SetParticleControl(effect_cast, 26, Vector(100, 0, 0))
                end

            end
        end

        -- attach particle effect to weapon wep 2
        if wearables_for_hero.particle_weapon_2 then
            for _, particle in pairs(wearables_for_hero.particle_weapon_2) do
                local effect_cast = ParticleManager:CreateParticle( particle.particle_string, PATTACH_ABSORIGIN_FOLLOW, hero )

                ParticleManager:SetParticleControlEnt(
                    effect_cast,
                    0,
                    hero,
                    PATTACH_POINT_FOLLOW,
                    particle.particle_attach_loc,
                    Vector(0,0,0),
                    true
                )

                if string.find(particle.particle_string, "phantom_assassin" ) then
                    ParticleManager:SetParticleControl(effect_cast, 9, Vector(-100, 0, 0))
                    ParticleManager:SetParticleControl(effect_cast, 26, Vector(100, 0, 0))
                end

            end
        end

        -- spawn parts if there are any...
        if wearables_for_hero.pet then
            local pet = CreateUnitByName(wearables_for_hero.pet, hero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
            pet:AddNewModifier( hero, nil, "companion_modifier", { duration = -1 } )
        end

        -- portait change over
        if wearables_for_hero.portrait then
            CustomGameEventManager:Send_ServerToAllClients( "update_player_frame_cosmetic_equipped", { player_id = hero:GetPlayerID(), hero_portrait = wearables_for_hero.portrait })
        end

        -- general stuff that takes too long to put into tables..
        if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
            local pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_elder_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(pfx, 0, hero, PATTACH_POINT_FOLLOW, "attach_leg_r", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 1, hero, PATTACH_POINT_FOLLOW, "attach_leg_l", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 2, hero, PATTACH_POINT_FOLLOW, "attach_hand_r", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 3, hero, PATTACH_POINT_FOLLOW, "attach_hand_l", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
        end

        if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" then
            local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_base_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)
        end

        if hero:GetUnitName() == "npc_dota_hero_queenofpain" then
            local particle = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_feet_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)

            local particle_2 = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_wings_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_2)

            local particle_3 = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_3)
        end

    end
end