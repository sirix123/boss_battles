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
                wearable["equipment"]["head"] = "models/items/crystal_maiden/frosty_valkyrie_head/frosty_valkyrie_head.vmdl"

                wearable["portrait"] = "npc_dota_hero_crystal_maiden_alt1"

                wearable["particle_weapon_1"] = {}
                wearable["particle_weapon_1"]["particle_settings"] = {}
                wearable["particle_weapon_1"]["particle_settings"]["particle_string"] = "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_staff_ambient.vpcf"
                wearable["particle_weapon_1"]["particle_settings"]["particle_attach_loc"] = "attach_attack1"

                self.pet = "npc_cm_cosmetic_pet"
                wearable["pet"] = self.pet

                wearable["modifier_arcana"] = "modifier_arcana_cosmetics"

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

                wearable["modifier_arcana"] = "modifier_arcana_cosmetics"

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "prod_JhhDjvKw86l9bm" then
                wearable["product_id"] = product_id

                self.model = "models/heroes/phantom_assassin/pa_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["head"] = "models/heroes/phantom_assassin/phantom_assassin_helmet.vmdl"
                wearable["equipment"]["weapon"] = "models/heroes/phantom_assassin/pa_arcana_weapons.vmdl"
                wearable["equipment"]["shoulders"] = "models/heroes/phantom_assassin/phantom_assassin_shoulders.vmdl"
                wearable["equipment"]["cape"] =  "models/heroes/phantom_assassin/phantom_assassin_cape.vmdl"
                wearable["equipment"]["daggers"] =  "models/heroes/phantom_assassin/phantom_assassin_daggers.vmdl"

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

            if product_id == "prod_JhhK4ZwCbpMAXe" then
                wearable["product_id"] = product_id

                self.model = "models/items/windrunner/windrunner_arcana/wr_arcana_base.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["head"] = "models/items/windrunner/windrunner_arcana/wr_arcana_head.vmdl"
                wearable["equipment"]["weapon"] = "models/items/windrunner/windrunner_arcana/wr_arcana_quiver.vmdl"
                wearable["equipment"]["shoulders"] = "models/items/windrunner/windrunner_arcana/wr_arcana_shoulder.vmdl"
                wearable["equipment"]["cape"] =  "models/items/windrunner/windrunner_arcana/wr_arcana_cape.vmdl"
                wearable["equipment"]["bow"] =  "models/items/windrunner/windrunner_arcana/wr_arcana_weapon.vmdl"
                wearable["equipment"]["legs"] =  "models/items/windrunner/windrunner_arcana/wr_arc_legs_scrolling.vmdl"

                wearable["particle_weapon_1"] = {}
                wearable["particle_weapon_1"]["particle_settings"] = {}
                wearable["particle_weapon_1"]["particle_settings"]["particle_string"] = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_bow_ambient.vpcf"
                wearable["particle_weapon_1"]["particle_settings"]["particle_attach_loc"] = "bow_mid1"

                wearable["portrait"] = "npc_dota_hero_windrunner_alt1"

                wearable["modifier_arcana"] = "modifier_arcana_cosmetics"

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "prod_JhhDnkjfU31G0U" then
                wearable["product_id"] = product_id

                wearable["portrait"] = "npc_dota_hero_lina_alt1"

                table.insert(self.wearable_table,wearable)
            end

            if product_id == "prod_JhhDluCT1T5SWR" then
                wearable["product_id"] = product_id

                self.model = "models/heroes/juggernaut/juggernaut_arcana.vmdl"
                wearable["model"] = self.model

                wearable["equipment"] = {}
                wearable["equipment"]["mask"] = "models/items/juggernaut/arcana/juggernaut_arcana_mask.vmdl"
                wearable["equipment"]["bracer"] = "models/heroes/juggernaut/jugg_bracers.vmdl"
                wearable["equipment"]["cape"] = "models/items/juggernaut/bladesrunner_back/bladesrunner_back.vmdl"
                wearable["equipment"]["wep"] = "models/items/juggernaut/generic_wep_broadsword.vmdl"
                wearable["equipment"]["legs"] = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"

                wearable["modifier_arcana"] = "modifier_arcana_cosmetics"

                wearable["portrait"] = "npc_dota_hero_juggernaut_alt1"

                table.insert(self.wearable_table,wearable)
            end

            -- omni
            if product_id == "prod_JhhDN4uB5R7qT4" then
                wearable["product_id"] = product_id

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

        if hero then
            print("hiding wearables")
            Wearables:HideWearables( hero )
        end

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

                if model == "models/items/juggernaut/arcana/juggernaut_arcana_mask.vmdl" then
                    local mask_particle = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, equipment )
                    ParticleManager:SetParticleControlEnt( mask_particle, 0, equipment, PATTACH_POINT_FOLLOW, "attach_tail" , equipment:GetOrigin(), true )
                    ParticleManager:SetParticleControlEnt( mask_particle, 1, equipment, PATTACH_POINT_FOLLOW, "attach_tail" , equipment:GetOrigin(), true )
                    ParticleManager:SetParticleControlEnt( mask_particle, 3, equipment, PATTACH_POINT_FOLLOW, "attach_tail" , equipment:GetOrigin(), true )
                    ParticleManager:SetParticleControlEnt( mask_particle, 4, equipment, PATTACH_POINT_FOLLOW, "attach_tail" , equipment:GetOrigin(), true )
                    ParticleManager:SetParticleControlEnt( mask_particle, 5, equipment, PATTACH_POINT_FOLLOW, "attach_tail" , equipment:GetOrigin(), true )
                    ParticleManager:SetParticleControl( mask_particle, 6, Vector(0, 0, 0) )
                end

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
                    ParticleManager:SetParticleControl(effect_cast, 9, Vector(0, 0, 0))
                    ParticleManager:SetParticleControl(effect_cast, 26, Vector(0, 0, 0))
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
                    ParticleManager:SetParticleControl(effect_cast, 9, Vector(0, 0, 0))
                    ParticleManager:SetParticleControl(effect_cast, 26, Vector(0, 0, 0))
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
        if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" and product_id == "prod_JhhDjvKw86l9bm" then
            local pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_elder_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(pfx, 0, hero, PATTACH_POINT_FOLLOW, "attach_leg_r", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 1, hero, PATTACH_POINT_FOLLOW, "attach_leg_l", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 2, hero, PATTACH_POINT_FOLLOW, "attach_hand_r", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pfx, 3, hero, PATTACH_POINT_FOLLOW, "attach_hand_l", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
        end

        if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" and product_id == "prod_JeM6EdQsCCvQbB" then
            local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_base_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)
        end

        if hero:GetUnitName() == "npc_dota_hero_queenofpain" and product_id == "prod_JhhDzGDJJb9t1z" then
            local particle = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_feet_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)

            local particle_2 = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_wings_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_2)

            local particle_3 = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_3)
        end

        if hero:GetUnitName() == "npc_dota_hero_windrunner" and product_id == "prod_JhhK4ZwCbpMAXe" then
            local particle = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)

            local particle_2 = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_2)

            local particle_3 = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient_mist.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_3)

            --[[local particle_4 = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_bowstring_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(
                particle_4,
                0,
                hero,
                PATTACH_POINT_FOLLOW,
                "bow_bot",
                Vector(0,0,0),
                true
            )

            ParticleManager:SetParticleControlEnt(
                particle_4,
                1,
                hero,
                PATTACH_POINT_FOLLOW,
                "bowstring",
                Vector(0,0,0),
                true
            )

            ParticleManager:SetParticleControlEnt(
                particle_4,
                2,
                hero,
                PATTACH_POINT_FOLLOW,
                "bow_top",
                Vector(0,0,0),
                true
            )
            ParticleManager:ReleaseParticleIndex(particle_4)]]

        end

        if hero:GetUnitName() == "npc_dota_hero_lina" and product_id == "prod_JhhDnkjfU31G0U" then
            ParticleManager:CreateParticle("particles/econ/items/lina/lina_blazing_cosmos/lina_blazing_cosmos_neck.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)

            local index = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_headflame.vpcf", PATTACH_POINT_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(index, 0, hero, PATTACH_POINT_FOLLOW, "attach_head", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(index)

            local index_2 = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_headflame.vpcf", PATTACH_POINT_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(index_2, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(index_2)

            local index_3 = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_headflame.vpcf", PATTACH_POINT_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(index_3, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack2", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(index_3)

            --[[local index_1 = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_flame_hand_dual_headflame.vpcf", PATTACH_POINT_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(index, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(index, 1, hero, PATTACH_POINT_FOLLOW, "attach_attack2", hero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(index_1)]]
        end

        if hero:GetUnitName() == "npc_dota_hero_juggernaut" and product_id == "prod_JhhDluCT1T5SWR" then
            local particle_1 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_body_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle_1)
        end

    end
end

--[[function Wearables:HideWearables( unit )
	local model = unit:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			model:AddEffects(EF_NODRAW)
            --model:AddNoDraw()
            --UTIL_Remove(model)
		end
		model = model:NextMovePeer()
	end
end]]

function Wearables:HideWearables(hUnit)
    for i, child in ipairs(hUnit:GetChildren()) do
        if IsValidEntity(child) and child:GetClassname() == "dota_item_wearable" then
            if child:GetModelName() ~= "" then
                UTIL_Remove(child)
            end
        end
    end
end
