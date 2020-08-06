WebApi = WebApi or {}

local apiKey = "AIzaSyAgI1IFKJFjkgLzpjCT1OvHOjgEBeEc-Wo"
local firebaseUrl = "https://boss-battles-84094.firebaseio.com/" 

function WebApi:SavePlayHistory(hero)
	local dedicatedServerKey =  GetDedicatedServerKeyV2("1")

	--Get 
	local heroname = hero:GetUnitName()
	local playerId = hero:GetPlayerID()
	local steamid = tostring(PlayerResource:GetSteamID(hero:GetPlayerID()))
	local dateTime = GetSystemDate() .. " " .. GetSystemTime()

	local data = {}
	data.dateTime = dateTime
	data.player = {}
	data.player.steamid = steamid
	data.player.playerName = "TODO:GetPlayerName?"
	data.ingame = {}
	data.ingame.classPlayed = heroname


	self:PostPlayHistory(data)
end


--Get stefan to login to Firebase website, watch the Real Time database. Then run this method
function WebApi:DemoForStefan()
	--Make a previously not existing db and populate with some data.

	--prepare some data, do loop to make a bunch of rows/entries
	local data = {}
	for i = 0, 10, 1 do
		data[i] = {}
		data[i].Text = [i] .. ". some text" -- make a string like: "1. some text"
		data[i].Value = i 
	end

	print(data)

	
	--Prepare http request:
	local firebasePath = firebaseUrl .. "stefansExampleDB.json"
	local request = CreateHTTPRequestScriptVM("POST", firebasePath) -- can be POST, GET, PUT, DELETE ... maybe some others?
	request:SetHTTPRequestRawPostBody("application/json", json.encode(dummyData))

	--make request and handle response:
	request:Send(function(response) 
		--ON SUCCESS:
		if response.StatusCode == 200 then
			print("POST request to " .. firebasePath .. " completed successfully")
		--ON ERROR/ anything else: 
		else
			print("POST request failed to send")
		end
	end)
		

	--another example:
	local playerObject = {}
	playerObject.playerName = "MooMoo"	
	playerObject.steamid = "873612836395-01" 
	playerObject.lastPlayed = "2020/06/08 17:25:38:634"
	playerObject.totalTimePlayed = "16:56"
	playerObject.totalBossesKilled = 78

	--no idea how achievements would actually be structured
	playerObject.achievements = {}
	playerObject.achievements.totalPoints = 7050
	
	--store a list of achievements this player has completed? or store all and then just toggle on completion?

	-- I just made up some achievements and this structure. It should probably be different!

	playerObject.achievements.NoDeaths = {}
	playerObject.achievements.NoDeaths.unlocked = true
	playerObject.achievements.NoDeaths.dateCompleted = "2020/06/08 17:25:38:634" 
	playerObject.achievements.NoDeaths.pointsValue = 500

	playerObject.achievements.KilledBossAfterWipe = {}
	playerObject.achievements.KilledBossAfterWipe.unlocked = false
	playerObject.achievements.KilledBossAfterWipe.dateCompleted = "null" 
	playerObject.achievements.KilledBossAfterWipe.pointsValue = 1800


	firebasePath = firebaseUrl .. "Example_Players.json"
	request = CreateHTTPRequestScriptVM("POST", firebasePath) -- can be POST, GET, PUT, DELETE ... maybe some others?
	request:SetHTTPRequestRawPostBody("application/json", json.encode(dummyData))

	--make request and handle response:
	request:Send(function(response) 
		--ON SUCCESS:
		if response.StatusCode == 200 then
			print("POST request to " .. firebasePath .. " completed successfully")
		--ON ERROR/ anything else: 
		else
			print("POST request failed to send")
		end
	end)


	-- TO GET THE DATA BACK INTO LUA:
	-- local request = CreateHTTPRequestScriptVM("GET", firebaseUrl .. "Example_Players.json")
	-- request:Send(function(response) 
	-- 	if response.StatusCode == 200 then -- HTTP 200 = Success
	-- 		local data = json.decode(response.Body)
	-- 		print("WebApi data = ", data)

	-- 		--TODO: Do something with the data;
	-- 			-- Show in panorama UI
	-- 			-- Use it to update the players progress in-game
	-- 			-- Store it so you can update it and POST it back later
	-- 	else 
	-- 		print("Http GET failed ", response.StatusCode)
	-- 	end
	-- end)
end


function WebApi:PostScoreboardDummyData()
	local dummyData = {}

	dummyData[1] = {} 
	dummyData[1].playerName = "Mitch"
	dummyData[1].Score = 123

	dummyData[2] = {} 
	dummyData[2].playerName = "Stefan"
	dummyData[2].Score = 123

	dummyData[3] = {} 
	dummyData[3].playerName = "Nic"
	dummyData[3].Score = 123

	dummyData[4] = {} 
	dummyData[4].playerName = "Marc"
	dummyData[4].Score = 123



	local firebasePath = firebaseUrl .. "testScoreboard.json"
	local request = CreateHTTPRequestScriptVM("POST", firebasePath)
	request:SetHTTPRequestRawPostBody("application/json", json.encode(dummyData))
	request:Send(function(response) 
		if response.StatusCode == 200 then
			print("POST request successfully sent to firebasePath = testScoreboard.json")
		else
			print("POST request failed to send")
		end
	end)


end


function WebApi:GetScoreboardTest()
	local request = CreateHTTPRequestScriptVM("GET", firebaseUrl .. "testScoreboard.json")

	request:Send(function(response) 
		if response.StatusCode == 200 then -- HTTP 200 = Success
			local data = json.decode(response.Body)
			print("WebApi data = ", data)
			return data
		else 
			print("WebApi Http GET failed ", response.StatusCode)
		end
	end)

end

function WebApi:PostPlayHistory(data)
	local request = CreateHTTPRequestScriptVM("POST", firebaseUrl ..  "/playHistory.json/")
	request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
      request:Send(function(response) 

        if response.StatusCode == 200 then
          print("POST request successfully sent")
        else
          print("POST request failed to send")
        end
      end)
end


function WebApi:PostData(data)
	local request = CreateHTTPRequestScriptVM("PUT", firebaseUrl ..  "/user/" ..data.steamid .. "/data.json")
	request:SetHTTPRequestRawPostBody("application/json", json.encode(data))

      request:Send(function(response) 
        if response.StatusCode == 200 then
          print("PUT request successfully sent")
        else
          print("PUT request failed to send")
        end
      end)
end


function WebApi:TestGet()
	print("WebApi:TestGet()")
	local request = CreateHTTPRequestScriptVM("GET", firebaseUrl .. "test.json")

	request:Send(function(response) 
		if response.StatusCode == 200 then -- HTTP 200 = Success
			local data = json.decode(response.Body)
			print("WebApi data = ", data)
		else 
			print("WebApi Http GET failed ", response.StatusCode)
		end
	end)
end

function WebApi:TestPost()
	local testData = {}
	testData.field1 = "Field1 Test data"
	testData.field2 = "Field2 Test data"

	local request = CreateHTTPRequestScriptVM("PUT", firebaseUrl .. "test.json")
	request:SetHTTPRequestRawPostBody("application/json", json.encode(testData))
      request:Send(function(response) 
        if response.StatusCode == 200 then
          print("PUT request successfully sent")
        else
          print("PUT request failed to send")
        end
      end)
end
