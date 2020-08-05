--[[ utility_functions.lua ]]

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
        --print("k1 = ",k1)
        --print("bossObjectContents = ",bossObjectContents)
        for k2, bosses in pairs(bossObjectContents.bosses) do
            --print("k2 = ",k2)
            --print("bosses = ",bosses)
            --for k3, v in pairs(bosses) do
                if bosses == enemy:GetUnitName() then
                    --print("v = ",v)
                    --print("enemny = ",enemy:GetUnitName())
                    return true
                end
            --end
        end
    end
end
