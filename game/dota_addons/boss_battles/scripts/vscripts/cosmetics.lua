if CosmeticManager == nil then
    CosmeticManager = class({})
end

function CosmeticManager:Init()

    -- init timer that checks db for changes
    CosmeticManager:CheckDatabaseForChanges()

    -- listen to buy button press
    CustomGameEventManager:RegisterListener('player_pressed_buy_button', function(eventSourceIndex, args)
        --print("player_pressed_buy_button ",event)

        local hPlayer = PlayerResource:GetPlayer(args.PlayerID)
        local player_steam_id = tostring(PlayerResource:GetSteamID(args.PlayerID))
        local url = "www.bossbattles.co" .. player_steam_id

        CustomGameEventManager:Send_ServerToPlayer( hPlayer, "open_shop_external", { url } )
    end)

    -- listen to equip button press
    CustomGameEventManager:RegisterListener('player_pressed_equip_button', function(eventSourceIndex, args)
        local hPlayer = PlayerResource:GetPlayer(args.PlayerID)
        local player_steam_id = tostring(PlayerResource:GetSteamID(args.PlayerID))
        local hero = PlayerResource:GetPlayer(args.PlayerID):GetAssignedHero()

        -- check if the player requesting to equip owns that cosmetic
        for _, hero in pairs(HERO_LIST) do
        end

        -- check if hero requesting to equip is allowed to equip that cosmetic
        for _, hero in pairs(HERO_LIST) do
        end

        -- if both pass from above then equip the cosmetic on the hero
        --[[if  then
            
        end]]

    end)

end

function CosmeticManager:CheckDatabaseForChanges()

    -- webapi call.... send list of the current players steamIDs.. send every 2mins...
    Timers:CreateTimer(0, function()
        if PICKING_DONE == true then

            local player_steam_ids = {}
            for _, hero in pairs(HERO_LIST) do
                local player_id = hero:GetPlayerID()
                local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))
                table.insert(player_steam_ids, player_steam_id)
            end

            --self.all_players_purchase_list = WebApi:GetPlayerPurchaseList( player_steam_ids )

            -- for testing only... (simulating the webapi sending data back)
            self.all_players_purchase_list = CosmeticManager:GetPlayerPurchaseListTest()


            return 120
        end
        return 1
    end)

    -- need another timer... to 'wait' for the endpoint to populate the array...
    Timers:CreateTimer(2, function()

        if self.all_players_purchase_list ~= nil then

            for _, hero in pairs(HERO_LIST) do
                local player_id = hero:GetPlayerID()
                local hPlayer = PlayerResource:GetPlayer(player_id)
                local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))

                for _, player in pairs(self.all_players_purchase_list) do
                    if player.steam_id == player_steam_id then
                        CustomGameEventManager:Send_ServerToPlayer( hPlayer, "update_shop_product_list", { player.purchases } )
                    end
                end
            end

            self.all_players_purchase_list = nil -- dont want to keep updating the shop with the same information every 2 seconds
        end

        return 2
    end)

end

function CosmeticManager:GetProductListTest()

    local product_list = {}
    local hero = {}
    hero["hero"] = "npc_dota_hero_crystal_maiden"
    hero["products"] = {"ed05d5ae-8383-47e1-9723-a8daa17c8695","ead33daf-8779-4b26-9a61-4841a7587302","39607c1c-7ed0-4377-a1f8-0d7d5ca980cf"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_juggernaut"
    hero["products"] = {"698c6222-4043-4dd0-8c2e-1b1c8c4c65cb"}
    table.insert(product_list,hero)

    --print(dump(json.encode(product_list)))

    return product_list
end


function CosmeticManager:GetPlayerPurchaseListTest()

    --[[
        schema..

    [{
		"steam_id": "76561197972850274",
		"purchases": [
			"ed05d5ae-8383-47e1-9723-a8daa17c8695",
			"ead33daf-8779-4b26-9a61-4841a7587302",
			"72dcceb3-8b39-431b-8c8c-d1c62d425d2e",
			"88daadbf-47bd-43f8-9805-aaabf44c1b7d"
		]
	},
	{
		"steam_id": "71356119797287328",
		"purchases": [
			"39607c1c-7ed0-4377-a1f8-0d7d5ca980cf",
			"698c6222-4043-4dd0-8c2e-1b1c8c4c65cb"
		]
    ]}

    ]]

    local product_player_list = {}

    local player = {}
    player["steam_id"] = "76561197972850274"
    player["purchases"] = {"ed05d5ae-8383-47e1-9723-a8daa17c8695","ead33daf-8779-4b26-9a61-4841a7587302","72dcceb3-8b39-431b-8c8c-d1c62d425d2e","88daadbf-47bd-43f8-9805-aaabf44c1b7d"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "11111111111111111"
    player["purchases"] = {"39607c1c-7ed0-4377-a1f8-0d7d5ca980cf","698c6222-4043-4dd0-8c2e-1b1c8c4c65cb"}
    table.insert(product_player_list,player)

    --print(dump(json.encode(product_player_list)))

    -- call function from webapi (GetProductList) or something

    return product_player_list
end
