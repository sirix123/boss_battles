if CosmeticManager == nil then
    CosmeticManager = class({})
end

function CosmeticManager:Init()
    --local purchase_list = CosmeticManager:GetPlayerPurchaseListTest()
    self.purchase_list = {} -- init
    CosmeticManager:GetPlayerPurchaseList() -- get the product list
    CosmeticManager:CheckDatabaseForChanges() -- checks database for player purchases every x interval

    self.product_list = {}
    CosmeticManager:GetProductList()

    -- wait for product_list to be populated, then map product list to wearables list
    Timers:CreateTimer(function()
        if #self.product_list > 0 then
            Wearables:MapWearablesToProductlist( self.product_list )
            return false
        end
        return 1
    end)

    -- if the webserver is down when the players load into the game don't allow players to do anything with the shop
    local timeout = 0
    Timers:CreateTimer(function()

        -- if these are nil it means the shop is down and we have no idea what player owns what
        -- when these variables initalise the below code runs once
        if ( self.purchase_list == nil or #self.product_list == 0) and PICKING_DONE == true then -- make sure all clients are ready / hero select is done

            if timeout >= 60 then
                return false
            end

            -- send event to clients that disables the open shop button
            CustomGameEventManager:Send_ServerToAllClients( "shop_status", { shop_status = false } )

            print("timeout ",timeout)

            timeout = timeout + 1

            return 1
        end

        -- if the lists arent nil means the shops are up and we are good to go
        if ( self.purchase_list ~= nil and #self.product_list ~= 0) and PICKING_DONE == true then -- make sure all clients are ready / hero select is done

            -- send event to clients that enables the open shop button
            CustomGameEventManager:Send_ServerToAllClients( "shop_status", { shop_status = true } )

            -- listen to buy button press
            CustomGameEventManager:RegisterListener('player_pressed_buy_button', function(eventSourceIndex, args)
                local hPlayer = PlayerResource:GetPlayer(args.PlayerID)
                local player_steam_id = tostring(PlayerResource:GetSteamID(args.PlayerID))
                local url = "143.198.224.131/Shop/Products?steam=" .. player_steam_id

                CustomGameEventManager:Send_ServerToPlayer( hPlayer, "open_shop_external", { url } )
            end)

            -- listen to equip button press
            CustomGameEventManager:RegisterListener('player_pressed_equip_button', function(eventSourceIndex, args)
                local hero = PlayerResource:GetPlayer(args.PlayerID):GetAssignedHero()

                local player_id = hero:GetPlayerID()
                local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))

                self.product_check = false
                self.product_to_equip = nil

                -- check for spoofing
                if self.purchase_list ~= nil then
                    for _, player in pairs(self.purchase_list) do
                        if player.steam_id == player_steam_id then -- check steamid matches from player purchase list (probs dont need this)
                            for _, product in pairs(self.product_list) do
                                if product.hero == hero:GetUnitName() then -- check the hero matches
                                    for _, product_id in pairs(product.products) do
                                        if args.product_id == product_id then -- check the player owns that cosmetic
                                            self.product_check = true
                                            self.product_to_equip = product_id
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- if both pass from above then equip the cosmetic on the hero
                if self.product_check == true and self.product_to_equip ~= nil and hero.arcana_equipped == false then

                    -- final check.. player must be alive...
                    if hero:IsAlive() == true then
                        Wearables:EquipWearables( self.product_to_equip , hero )
                    end

                end
            end)

            return false
        end
        return 1
    end)
end

function CosmeticManager:CheckDatabaseForChanges()

    -- webapi call.... send list of the current players steamIDs.. send every 2mins...
    Timers:CreateTimer(20,function()
        if PICKING_DONE == true then -- need to remove this later but need to figure out how to get steam id's eariler...

            -- for testing only... (simulating the webapi sending data back)
            self.purchase_list = {}
            CosmeticManager:GetPlayerPurchaseList()
            --print("CosmeticManager:CheckDatabaseForChanges() self.purchase_list, ",self.purchase_list)

            return 20
        end
        return 1
    end)

    -- need another timer... to 'wait' for the endpoint to populate the array...
    Timers:CreateTimer(2, function()

        if self.purchase_list ~= nil and self.purchase_list ~= 0 then

            for _, hero in pairs(HERO_LIST) do
                local player_id = hero:GetPlayerID()
                local hPlayer = PlayerResource:GetPlayer(player_id)
                local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))

                for _, player in pairs(self.purchase_list) do
                    if player.steam_id == player_steam_id then
                        CustomGameEventManager:Send_ServerToPlayer( hPlayer, "update_shop_product_list", { player.purchases } )
                    end
                end
            end

            --self.purchase_list = {} -- dont want to keep updating the shop with the same information every 2 seconds
        end

        return 2
    end)

end

function CosmeticManager:GetProductList()
  --This wasn't working. req1 will be nil. It happens too quick after the server has started.
  --local req1 = CreateHTTPRequestScriptVM("GET", "http://bossbattles.co/Shop/GetBossBattlesProducts")

  -- A solution to the above is to delay for some time before using CreateHTTPRequestScriptVM 
  Timers:CreateTimer(1, function() -- A timer that starts x seconds in the future, respects pauses
    local request = CreateHTTPRequestScriptVM("GET", "http://bossbattles.co/Shop/GetBossBattlesProducts")
        request:Send(function(response)
        if response.StatusCode == 200 then -- HTTP 200 = Success
          local data = json.decode(response.Body)
          --print("GetProductList() returning. data = ", dump(data))
          self.product_list = data
          --return data
        else
          print("GetProductList Http GET failed ", response.StatusCode)
        end
      end)
    end)
end

function CosmeticManager:GetProductListTest()

    local product_list = {}
    local hero = {}
    hero["hero"] = "npc_dota_hero_crystal_maiden"
    hero["products"] = {"prod_JeM6EdQsCCvQbB"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_juggernaut"
    hero["products"] = {"prod_JhhDluCT1T5SWR"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_queenofpain"
    hero["products"] = {"prod_JhhDzGDJJb9t1z"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_windrunner"
    hero["products"] = {"prod_JhhK4ZwCbpMAXe"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_phantom_assassin"
    hero["products"] = {"prod_JhhDjvKw86l9bm"}
    table.insert(product_list,hero)

    hero = {}
    hero["hero"] = "npc_dota_hero_lina"
    hero["products"] = {"prod_JhhDnkjfU31G0U"}
    table.insert(product_list,hero)

    --print(dump(json.encode(product_list)))

    return product_list
end

function CosmeticManager:GetPlayerPurchaseList()
    --local product_player_list = {}
    if PICKING_DONE == true then -- need to remove this later but need to figure out how to get steam id's eariler...
        --get all the players steam_ids to find out who has purchased products
        local player_steam_ids = {}
        for _, hero in pairs(HERO_LIST) do
            local player_id = hero:GetPlayerID()
            local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))
            table.insert(player_steam_ids, player_steam_id)
        end

        local dataToSend = {}
        dataToSend["playersSteamIds"] = player_steam_ids
        local dataToSendJson = json.encode(dataToSend)
        --print("sending this data to /shop/GetPlayersOrders" , dump(dataToSendJson))

        -- call the api: /shop/GetPlayersOrders and send the player steam id table
        if IsServer() then
            local request = CreateHTTPRequestScriptVM("POST", "http://143.198.224.131/shop/GetPlayersOrders")
            --local request = CreateHTTPRequestScriptVM("POST", "https://localhost:5001/shop/GetPlayersOrders")
            request:SetHTTPRequestRawPostBody("application/json", dataToSendJson)
            request:Send(function(response) 
                if response.StatusCode == 200 then -- HTTP 200 = Success
                    --TODO: send cosmetic data, send packet to each client?
                    local data = json.decode(response.Body)
                    --print("got response. data = ", dump(data))

                    for steamId, productTable in pairs(data) do
                        --print("steamid = ", steamId )
                        --print("productTable = ", productTable )
                        -- print("dump(productTable) = ", dump(productTable) )

                        local player = {}
                        player["steam_id"] = steamId
                        player["purchases"] = productTable
                        table.insert(self.purchase_list,player)
                    end
                    --CustomGameEventManager:Send_ServerToAllClients( "loading_screen_data", data )
                    --return product_player_list
                 else
                     print("Http GET failed ", response.StatusCode)
                 end

            end)
        end
    end
    --return nil
end

function CosmeticManager:GetPlayerPurchaseListTest()
    local product_player_list = {}


    if PICKING_DONE == true then -- need to remove this later but need to figure out how to get steam id's eariler...
        --get all the players steam_ids to find out who has purchased products
        local player_steam_ids = {}
        for _, hero in pairs(HERO_LIST) do
            local player_id = hero:GetPlayerID()
            local player_steam_id = tostring(PlayerResource:GetSteamID(player_id))
            table.insert(player_steam_ids, player_steam_id)
        end

        local dataToSend = {}
        dataToSend["playersSteamIds"] = player_steam_ids
        local dataToSendJson = json.encode(dataToSend)
        --print("sending this data to /shop/GetPlayersOrders" , dump(dataToSendJson))

        -- call the api: /shop/GetPlayersOrders and send the player steam id table
        if IsServer() then
            local request = CreateHTTPRequestScriptVM("POST", "http://143.198.224.131/shop/GetPlayersOrders")
            --local request = CreateHTTPRequestScriptVM("POST", "https://localhost:5001/shop/GetPlayersOrders")
            request:SetHTTPRequestRawPostBody("application/json", dataToSendJson)
            request:Send(function(response) 
                if response.StatusCode == 200 then -- HTTP 200 = Success
                    --TODO: send cosmetic data, send packet to each client?
                    local data = json.decode(response.Body)
                    --print("got response. data = ", dump(data))

                    for steamId, productTable in pairs(data) do
                        -- print("steamid = ", steamId )
                        -- print("productTable = ", productTable )
                        -- print("dump(productTable) = ", dump(productTable) )

                        local player = {}
                        player["steam_id"] = steamId
                        player["purchases"] = productTable
                        table.insert(product_player_list,player)
                    end
                    --CustomGameEventManager:Send_ServerToAllClients( "loading_screen_data", data )
                    return data
                 else
                     print("Http GET failed ", response.StatusCode)
                 end
            end)
        end
    end

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
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198054593305"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198015252302"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198261513304"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198088786586"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198028107754"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198077897720"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    player = {}
    player["steam_id"] = "76561198000305117"
    player["purchases"] = {"prod_JhhDjvKw86l9bm","prod_JhhDnkjfU31G0U","prod_JhhK4ZwCbpMAXe","prod_JhhDN4uB5R7qT4","prod_JhhDzGDJJb9t1z","prod_JhhDluCT1T5SWR","prod_JeM6EdQsCCvQbB"}
    table.insert(product_player_list,player)

    --print(dump(json.encode(product_player_list)))

    -- call function from webapi (GetProductList) or something

    return product_player_list
end
