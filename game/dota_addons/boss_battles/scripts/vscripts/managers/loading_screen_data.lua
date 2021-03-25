if loading_screen_data == nil then
    loading_screen_data = class({})
end
----------------------------------------------------------------------------------------

-- grab data from the server
function loading_screen_data:GetLeaderBoardData()
    if IsServer() then

        self.data = self:DummyData()

        -- function to use the normal mode top 10 endpoint (returns an object)

        -- function to use the hard mode top 10 endpoint (returns an object)

        -- combine the data into one table

    end
end

-- send data to front end, if client is ready
function loading_screen_data:SendLeaderBoardData()
    if IsServer() then

        -- holy shit.. the server really does send data when the client isn't ready (without this delay the data wont display for the client)
        Timers:CreateTimer(5,function ()
            self:GetLeaderBoardData()

            print("sending data")

            CustomGameEventManager:Send_ServerToAllClients( "loading_screen_data", self.data )
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