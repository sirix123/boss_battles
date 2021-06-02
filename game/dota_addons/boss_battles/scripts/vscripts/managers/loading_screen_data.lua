if loading_screen_data == nil then
    loading_screen_data = class({})
end
----------------------------------------------------------------------------------------

-- send data to front end, if client is ready
function loading_screen_data:SendLeaderBoardData()
    if IsServer() then
        -- holy shit.. the server really does send data when the client isn't ready (without this delay the data wont display for the client)
        Timers:CreateTimer(5,function ()
            -- make the http request and send the data to clients once it returns. 
            self:GetLeaderBoardDataFromApi()
        end)
    end
end


-- TODO: implement version with parametized mode
-- function loading_screen_data:GetLeaderBoardDataFromApi(mode)
    -- local request = CreateHTTPRequestScriptVM("GET", "http://143.198.224.131/api/leaderboard?mode="..mode)
function loading_screen_data:GetLeaderBoardDataFromApi()
    if IsServer() then
        local request = CreateHTTPRequestScriptVM("GET", "http://143.198.224.131/api/leaderboard?mode=normalMode")
        --local request = CreateHTTPRequestScriptVM("GET", "https://localhost:44363/api/leaderboard?mode=MOCK")
        request:Send(function(response) 
         if response.StatusCode == 200 then -- HTTP 200 = Success
            local data = json.decode(response.Body)
            CustomGameEventManager:Send_ServerToAllClients( "loading_screen_data", data )
            return data
         else 
             print("Http GET failed ", response.StatusCode)
         end
        end)

    end
end

-- generate some dummy data
function loading_screen_data:DummyData()
    if IsServer() then

        local top10 = {}
        local nRanks = 10

        for i = 1, nRanks, 1 do
            local entry = {}

            entry["rank"] = i
            entry["playerData"] =
            {
                {
                    name = "Stefan",
                    hero = "Ice Mage",
                    lives_remaining = "0",
                },
                {
                    name = "Mike",
                    hero = "Purple Mage",
                    lives_remaining = "1",
                },
                {
                    name = "Marc",
                    hero = "Fire Mage",
                    lives_remaining = "2",
                },
                {
                    name = "Nic",
                    hero = "Green Mage",
                    lives_remaining = "3",
                },
            }
            entry["boss_1_time"] = "20:00"
            entry["boss_2_time"] = "10:00"
            entry["boss_3_time"] = "00:00"
            entry["boss_4_time"] = "00:00"
            entry["boss_5_time"] = "90:00"
            entry["boss_6_time"] = "39:00"
            entry["boss_total_time"] = "99:00"

            table.insert(top10,entry)

            --[[{
                top10[i] =
                {
                    "rank": i + 1,
                    "playerData":
                        [
                            {
                                "name": "Stefan",
                                "hero": "Fire Mage",
                                "lives_remaining": "3"
                            },
                        
                            {
                                "name": "Marc",
                                "hero": "Ice Mage",
                                "lives_remaining": "0"
                            },
        
                            {
                                "name": "Mike",
                                "hero": "Purple Mage",
                                "lives_remaining": "1"
                            },
                        
                            {
                                "name": "Ryan",
                                "hero": "Palla",
                                "lives_remaining": "2"
                            }
                        ],
        
                    "boss_1_time": "30:00",
                    "boss_2_time": "23:00",
                    "boss_3_time": "00:10",
                    "boss_4_time": "30:20",
                    "boss_5_time": "30:60",
                    "boss_6_time": "90:00",
                    "boss_total_time": "01:30:00"
                }
            }]]
        end

        return top10
    end
end