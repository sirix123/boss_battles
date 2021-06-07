--[[ utility_functions.lua ]]


---String mapping functions to translate dota terms into our game terms
function GetClassName(unitName)
	local unitNameClassNameMap = {}
	unitNameClassNameMap["npc_dota_hero_crystal_maiden"] = "Rylai"
	unitNameClassNameMap["npc_dota_hero_medusa"] = "Medusa"
	unitNameClassNameMap["npc_dota_hero_phantom_assassin"] = "Nightblade"
	unitNameClassNameMap["npc_dota_hero_lina"] = "Lina"
	unitNameClassNameMap["npc_dota_hero_omniknight"] = "Nocens"
	unitNameClassNameMap["npc_dota_hero_queenofpain"] = "Akasha"
	unitNameClassNameMap["npc_dota_hero_juggernaut"] = "Blademaster"

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
function FindUnitsInCone(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, endRadius + flLength, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local enemy_distance_from_caster = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )

				-- Author of this "increase over distance": Fudge, pretty proud of this :D (THANKS FUDGE!)

				-- Calculate how much the width of the check can be higher than the starting point
				local max_increased_radius_from_distance = endRadius - startRadius

				-- Calculate how close the enemy is to the caster, in comparison to the total distance
				local pct_distance = enemy_distance_from_caster / flLength

				-- Calculate how much the width should be higher due to the distance of the enemy to the caster.
				local radius_increase_from_distance = max_increased_radius_from_distance * pct_distance

				if ( flSideAmount < startRadius + radius_increase_from_distance ) and ( enemy_distance_from_caster > 0.0 ) and ( enemy_distance_from_caster < flLength ) then
					table.insert(unitTable, enemy)
				end
			end
		end
	end
	return unitTable
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

function FindEnemyUnitsInRing(position, maxRadius, minRadius, team, flags)
		local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = DOTA_UNIT_TARGET_ALL
		local iFlag = flags --DOTA_UNIT_TARGET_FLAG_INVULNERABLE
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

-- create boss numbers 
function BossNumbersOnTarget(hTarget, nAmount, vColour)
	local word_length = string.len(tostring(math.floor(nAmount)))

	local color =  vColour
	local effect_cast = ParticleManager:CreateParticle("particles/boss_numbers_custom_msg_damage.vpcf", PATTACH_WORLDORIGIN, nil) 
	ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, nAmount, 0))
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(0.5, word_length, 0))
	ParticleManager:SetParticleControl(effect_cast, 3, color)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function isPointInsidePolygon(point, polygon)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
            if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                oddNodes = not oddNodes
            end
        end
        j = i
    end
    return oddNodes
end

function CustomGetCastPoint(caster,ability)
	--print("caster ",caster,"ability ",ability)

	if caster:HasModifier("e_whirling_winds_modifier") == true and ability:GetAbilityIndex() == 0 then
        return ability:GetCastPoint() - ( ability:GetCastPoint() * flWHIRLING_WINDS_CAST_POINT_REDUCTION )
	else
		return ability:GetCastPoint()
	end
end

function DestroyItems( location )
	local objs = Entities:FindAllByClassnameWithin("dota_item_drop", location, 10000)
	for _, obj in pairs(objs) do
		UTIL_Remove(obj)
	end
end

-- check global modifier table, return ttrue if passed in modifier is a core modifier
function CheckGlobalModifierTable(modifierName)
    for _, modifier in pairs(tCORE_MODIFIERS) do
        if modifier == modifierName then
            return true
        end
    end
end

function FindCloestUnitInALine( hCaster, vOrigin, vTarget, nWidth)
	local units = FindUnitsInLine(
		hCaster:GetTeamNumber(),
		vOrigin,
		vTarget,
		nil,
		nWidth,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

	if units == nil or #units == 0 then
		return nil
	end

	local previous_distance = 999999
	local close_target = nil
	for k, unit in pairs(units) do
		if unit:GetUnitName() == hCaster:GetUnitName() then
			table.remove(units,k)
		end
	end

	for _, unit in pairs(units) do
		local distance = ( hCaster:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D()
		if distance < previous_distance then
			close_target = unit
		end
		previous_distance = distance
	end

	return close_target
end

function TableContains(tab, val)
    for index, value in ipairs(tab) do
		print("value: ",value,"inc val: ",val)
        if value == val then
            return true
        end
    end

    return false
end

function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function GenerateGUID()
	local guid = {};

	guid.char = {"A", "B", "C", "D", "E", "F","1","2","3","4","5","6","7","8","9"};
	guid.isHyphen = {[9]=1,[14]=1,[19]=1,[24]=1};
	guid.used = {};
	guid.loops = 0;

	math.randomseed(GetSystemTimeMS());

	guid.currentGuid = nil;
	while(true) do
		guid.loops = guid.loops +1;
		--If we can't get it in 20 tries than we have bigger problems.
		if(guid.loops > 20) then return false; end
		guid.pass = {};
		for z = 1,36 do
			if guid.isHyphen[z] then
				guid.x='-';
			else
				guid.a = math.random(1,#guid.char); -- randomly choose a character from the "guid.char" array
				guid.x = guid.char[guid.a]
			end
				table.insert(guid.pass, guid.x) -- add new index into array.
		end

		z = nil
		guid.currentGuid = tostring(table.concat(guid.pass)); -- concatenate all indicies of the array, then return concatenation.
		if not guid.used[guid.currentGuid] then

			guid.used[guid.currentGuid] = guid.currentGuid;
			return(guid.currentGuid);
		else
			--print('Duplicated a Previously Created GUID.');
		end
	end
end
