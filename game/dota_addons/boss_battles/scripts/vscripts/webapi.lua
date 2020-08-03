WebApi = WebApi or {}

local apiKey = "AIzaSyAgI1IFKJFjkgLzpjCT1OvHOjgEBeEc-Wo"
local firebaseUrl = "https://boss-battles-84094.firebaseio.com/" 


function WebApi:TestFunction(hero)
	local dedicatedServerKey =  GetDedicatedServerKeyV2("1")

	--Get 
	local heroname = hero:GetUnitName()
	local playerId = hero:GetPlayerID()
	local steamid = PlayerResource:GetSteamID(hero:GetPlayerID())

	local date =  GetSystemDate()
	local time = GetSystemTime()
	local dateTime = date .. " " .. time

	local data = {}
	data.dateTime = dateTime
	data.player = {}
	data.player.steamid = tostring(steamid)
	data.player.playerName = "TODO:GetPlayerName?"
	data.ingame = {}
	data.ingame.classPlayed = heroname

	self:PostPlayHistory(data)
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
