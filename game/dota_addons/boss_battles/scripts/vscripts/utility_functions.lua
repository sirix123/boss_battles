--[[ utility_functions.lua ]]


---String mapping functions to translate dota terms into our game terms
function GetClassName(unitName)
	local unitNameClassNameMap = {}
	unitNameClassNameMap["npc_dota_hero_crystal_maiden"] = "ice_mage"
	unitNameClassNameMap["npc_dota_hero_medusa"] = "ranger"
	unitNameClassNameMap["npc_dota_hero_phantom_assassin"] = "rogue"
	unitNameClassNameMap["npc_dota_hero_juggernaut"] = "warlord"

	if unitNameClassNameMap[unitName] ~= nil then
		return unitNameClassNameMap[unitName] 
	else
		return "no_class_name"
	end
end


--class name like: ice_mage, ranger, rogue, warlord
function GetClassIcon(className)
    --TODO: for each class get the icon file/location
    if className == "ice_mage" then 
    	return "file://{images}/class_icons/icon_staff.png"
    end
    if className == "ranger" then 
    	return "file://{images}/class_icons/icon_bow.png"
    end
    if className == "rogue" then 
    	return "file://{images}/class_icons/icon_sword.png"
    end
    if className == "warlord" then 
    	return "file://{images}/class_icons/icon_person.png"
    end

    return "file://{images}/class_icons/icon_person.png"
end


---------------------------------------------------------------------------
-- Handle messages
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( TableCount(reference_list) == 0 ) then
        return nil
    end
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        local i = 1
        for k, v in pairs(reference_list) do
            bucket[i] = v
            i = i + 1
        end
    end
    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

-- enters the list of bosses, order = defined as in the file, stores in array
function GetListOfBossesInOrder(reference_list, bucket)
    if ( TableCount(reference_list) == 0 ) then
        return nil
    end
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        local i = 1
        for k, v in pairs(reference_list) do
            bucket[i] = v
            i = i + 1
        end
    end
    return bucket
end

function GetRandomTableElement( myTable )
    -- iterate over whole table to get all keys
    local keyset = {}
    for k in pairs(myTable) do
        table.insert(keyset, k)
    end
    -- now you can reliably return a random key
    return myTable[keyset[RandomInt(1, #keyset)]]
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function ConvertTimeToTable(t)
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    return broadcast_gametimer
end

function GetCurrentTime()
    return ConvertTimeToTable(math.max(nCOUNTDOWNTIMER, 0))
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    broadcast_gametimer = GetCurrentTime()
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    -- if nCOUNTDOWNTIMER <= 120 then
    --     CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    -- end
end

function SetTimer( time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end

-- find units in a cone
-- fMinProjection is a value from -1 to 1, 1 when the unit is aligned with vDirection, -1 is the vector opposite to vDirection
function FindUnitsInCone(nTeamNumber, vDirection, fMinProjection, vCenterPos, fRadius, hCacheUnit, nTeamFilter, nTypeFilter, nFlagFilter, nOrderFilter, bCanGrowCache)
	local units = FindUnitsInRadius(
		nTeamNumber,	-- int, your team number
		vCenterPos,	-- point, center point
		hCacheUnit,	-- handle, cacheUnit. (not known)
		fRadius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		nTeamFilter,	-- int, team filter
		nTypeFilter,	-- int, type filter
		nFlagFilter,	-- int, flag filter
		nOrderFilter,	-- int, order filter
		bCanGrowCache	-- bool, can grow cache
	)

	-- Filter within cone
	local targets = {}
	for _,unit in pairs(units) do
		local direction = (unit:GetAbsOrigin() - vCenterPos):Normalized()
        local projection = direction.x * vDirection.x + direction.y * vDirection.y

		if projection >= fMinProjection then
			table.insert(targets, unit)
		end
    end

	return targets
end

-- clamps target point
function Clamp(origin, point, max_range, min_range)
	local direction = (point - origin):Normalized()
	local distance = (point - origin):Length2D()
	local output_point = point

	if max_range then
		if distance > max_range then
			output_point = origin + direction * max_range
		end
	end

	if min_range then
		if distance < min_range then
			output_point = origin + direction * min_range
		end
	end

	return output_point
end

-- check raid tables if bosses exists
function CheckRaidTableForBossName(enemy)
    for k1, bossObjectContents in pairs(tRAID_INIT_TABLE) do
        if bossObjectContents.boss == enemy:GetUnitName() then
            return true
        end
    end
end

-- check globals to see if projectiles should be allowed to hit things
function CheckGlobalUnitTableForUnitName(enemy)
	for _, unit in pairs(tUNIT_TABLE) do
		--print("CheckGlobalUnitTableForUnitName unit", unit)
		if unit == enemy:GetUnitName() then
			--print("are we returning true? ")
			return true
        end
    end
end

function PrintTable(t, indent, done)
	--print (string.format ('PrintTable type %s', type(keys)))
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	local canCompare = true
	for k, v in pairs(t) do
		table.insert(l, k)
		if type(k) == "table" then
			canCompare = false
		end
	end

	if canCompare then
		table.sort(l)
	end
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
		local value = t[v]

		if type(value) == "table" and not done[value] then
			done [value] = true
			print(string.rep ("\t", indent)..tostring(v)..":")
			PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
			done [value] = true
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
			PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
			if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
			else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
			end
		end
		end
	end
end

function FindEnemyUnitsInRing(position, maxRadius, minRadius, team)
		local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = DOTA_UNIT_TARGET_ALL
		local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = FIND_ANY_ORDER

		local innerRing = FindUnitsInRadius(team, position, nil, minRadius, iTeam, iType, iFlag, iOrder, false)
		local outerRing = FindUnitsInRadius(team, position, nil, maxRadius, iTeam, iType, iFlag, iOrder, false)

		--DebugDrawCircle(position,Vector(255,0,0),128,maxRadius,true,60)
		--DebugDrawCircle(position,Vector(0,0,255),128,minRadius,true,60)

		local resultTable = {}
		for _, unit in ipairs(outerRing) do
			if not unit:IsNull() then
				local addToTable = true
				for _, exclude in ipairs(innerRing) do
					if unit == exclude then
						addToTable = false
						break
					end
				end
				if addToTable then
					table.insert(resultTable, unit)
				end
			end
		end
		return resultTable
end

function Dot(a, b)
    return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3])
end

function Mag(a)
    return math.sqrt((a[1] * a[1]) + (a[2] * a[2]) + (a[3] * a[3]))
end


--STRING SPLIT FUNCTION FROM: https://stackoverflow.com/questions/42650340/how-to-get-first-character-of-string-in-lua
function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- create text on target
function NumbersOnTarget(hTarget, nAmount, vColour)
	local word_length = string.len(tostring(math.floor(nAmount)))

	local color =  vColour
	local effect_cast = ParticleManager:CreateParticle("particles/custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) 
	ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, nAmount, 0))
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(0.5, word_length, 0)) 
	ParticleManager:SetParticleControl(effect_cast, 3, color)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
