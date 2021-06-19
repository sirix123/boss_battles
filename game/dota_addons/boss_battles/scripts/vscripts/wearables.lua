if Wearables == nil then
    Wearables = class({})
end

function Wearables:MapWearablesToProductlist( product_list )

    self.wearable_table = {}

    for _, product in pairs(product_list) do
        for _, product_id in pairs(product.products) do
            local wearable = {}

            if product_id == "ed05d5ae-8383-47e1-9723-a8daa17c8695" then
                wearable["product_id"] = product_id

                self.model = "models/heroes/crystal_maiden/crystal_maiden_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["weapon"] = "models/items/crystal_maiden/cm_ti9_immortal_weapon/cm_ti9_immortal_weapon.vmdl"
                --wearable["equipment"]["bracer"] = "bracer"

                --wearable["particles"] = {}
                --wearable["particles"]["1"] = ...

                -- wearable["pets"] = {}
                -- wearable["pets"]["1"] = ...

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "1111111-4043-4dd0-8c2e-1b1c8c4c65cb" then
                wearable["product_id"] = product_id

                self.model = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["armor"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_armor.vmdl"
                wearable["equipment"]["weapon"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_dagger.vmdl"
                wearable["equipment"]["hair"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl"
                wearable["equipment"]["wings"] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_wings.vmdl"

                wearable["portrait"] = "npc_dota_hero_queenofpain_alt1"

                wearable["particle_weapon"] = {}
                wearable["particle_weapon"]["particle_settings"] = {}
                wearable["particle_weapon"]["particle_settings"]["particle_string"] = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blade_ambient.vpcf"
                wearable["particle_weapon"]["particle_settings"]["particle_attach_loc"] = "attach_attack1"

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

        -- attach particle effect to weapon
        if wearables_for_hero.particle_weapon then
            for _, particle in pairs(wearables_for_hero.particle_weapon) do
                local effect_cast = ParticleManager:CreateParticle( particle.particle_string, PATTACH_POINT_FOLLOW, hero )

                ParticleManager:SetParticleControlEnt(
                    effect_cast,
                    0,
                    hero,
                    PATTACH_POINT_FOLLOW,
                    particle.particle_attach_loc,
                    Vector(0,0,0),
                    true
                )
            end
        end

        -- spawn parts if there are any...
        --if wearables_for_hero.pets then
            --for _, pet in pairs(wearables_for_hero.pets) do
                -- spawn the pet
                -- give it the modifier from earthsalamnder
            --end
        --end

        -- portait change over
        --update_player_frame_cosmetic_equipped
        -- CustomGameEventManager:Send_ServerToAllClients( "send_product_list", CosmeticManager:GetProductListTest())
        if wearables_for_hero.portrait then
            CustomGameEventManager:Send_ServerToAllClients( "update_player_frame_cosmetic_equipped", { player_id = hero:GetPlayerID(), hero_portrait = wearables_for_hero.portrait })
        end

    end
end