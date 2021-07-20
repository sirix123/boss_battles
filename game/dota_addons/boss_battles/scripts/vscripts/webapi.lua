WebApi = WebApi or {}


function WebApi:SaveSessionData(data)
	local request = CreateHTTPRequestScriptVM("POST","http://143.198.224.131/session/data")
	request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
      request:Send(function(response) 
        if response.StatusCode == 200 then
          	print("POST request successfully sent")
        else
         	print("POST request failed to send")
			print("ERROR CODE: ",response.StatusCode)
			print("ERROR CODE: ",print(dump(response)))
        end
      end)
end

function WebApi:GetScoreboardData(heroIndex)
	print("WebApi:GetScoreboardData()" )

	print("Using Dummy data for scoreboard" )	
	local dummyData = WebApi:GetDummyScoreboardData()

	--HACK: hardcoded to test one val
    --dummyData[1].dmgDone = _G.DamageTotalsTable[heroIndex]["totalDmg"]
	_G.scoreboardData = dummyData

    if _G.scoreboardData == nil then
        CustomGameEventManager:Send_ServerToAllClients("setupScoreboard", dummyData)
    end
end

function WebApi:GetProductList()
	local request = CreateHTTPRequestScriptVM("GET", "http://bossbattles.co/Shop/GetBossBattlesProducts")

	request:Send(function(response)
		if response.StatusCode == 200 then -- HTTP 200 = Success
			print("GOT productlist. response.body = ", response.body)
			return json.decode(response.body)
		else
			print("WebApi Http GET failed ", response.StatusCode)
		end
	end)
end

--Recursively convert a table to string
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end