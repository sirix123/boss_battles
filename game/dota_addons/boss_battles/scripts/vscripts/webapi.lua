WebApi = WebApi or {}


function WebApi:SaveSessionData(data)
-- local request = CreateHTTPRequestScriptVM("POST","https://www.sdgames.co/boss_battles/post_session_data")
local request = CreateHTTPRequestScriptVM("POST","https://www.sdgames.co/boss_battles/post_session_data")
request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
      request:Send(function(response) 
        if response.StatusCode == 200 then
          print("SESSION - POST request successfully sent")
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
_G.scoreboardData = dummyData
    if _G.scoreboardData == nil then
        CustomGameEventManager:Send_ServerToAllClients("setupScoreboard", dummyData)
    end
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