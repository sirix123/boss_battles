
--[[
 Hero selection module for D2E.
 This file basically just separates the functions related to hero selection from
 the other functions present in D2E.
]]

--Class definition
if HeroSelection == nil then
	HeroSelection = {}
	HeroSelection.__index = HeroSelection
end

--[[
	Start
	Call this function from your gamemode once the gamestate changes
	to pre-game to start the hero selection.
]]
function HeroSelection:Start()

	print("PLAYERS_HANDSHAKE_READY ",PLAYERS_HANDSHAKE_READY)
	print("PlayerResource:GetPlayerCount() ",PlayerResource:GetPlayerCount())

	--or PICKING_DONE == false and IsInToolsMode() == true

	if PICKING_DONE == false and PLAYERS_HANDSHAKE_READY == PlayerResource:GetPlayerCount()  then

		--print("are we sending the open hero select event?")

		local copy_hero_name_list = HERO_NAME_LIST

		if IsInToolsMode() == true then

			table.insert(copy_hero_name_list,"npc_dota_hero_templar_assassin")
			table.insert(copy_hero_name_list,"npc_dota_hero_kunkka")
			table.insert(copy_hero_name_list,"npc_dota_hero_grimstroke")
			table.insert(copy_hero_name_list,"npc_dota_hero_hoodwink")
			table.insert(copy_hero_name_list,"npc_dota_hero_oracle")

		end

		CustomGameEventManager:Send_ServerToAllClients( "begin_hero_select", { hero_list = copy_hero_name_list})

		HeroSelection.numPickers = PlayerResource:GetPlayerCount()
		HeroSelection.playersPicked  = 0
		HeroSelection.playerPicks = {}
		HeroSelection.playerSelects = {}

		--Listen for the pick event
		HeroSelection.listener = CustomGameEventManager:RegisterListener( "hero_picked", HeroSelection.HeroPicked )

		--Listen for the select event
		HeroSelection.listener = CustomGameEventManager:RegisterListener( "hero_selected", HeroSelection.HeroSelected )

	end
end

--[[
	HeroSelect
	A player has selected a hero. This function is caled by the CustomGameEventManager
	once a 'hero_selected' event was seen.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroSelected( event )

	-- i think here.. we need to collect all the heroes into a an array index being the slot then send the array of hero names to js
	--print("event.Index ",event.PlayerID)
	--print("event.HeroName ",event.HeroName)

	-- Send a select event to all clients with the array of heroes
	CustomGameEventManager:Send_ServerToAllClients( "picking_player_selected", 
		{ PlayerID = event.PlayerID, HeroName = event.HeroName } )
end

--[[
	HeroPick
	A player has picked a hero. This function is caled by the CustomGameEventManager
	once a 'hero_picked' event was seen.
	Params:
		- event {table} - A table containing PlayerID and HeroID.
]]
function HeroSelection:HeroPicked( event )

	-- js calls this when a player picks a hero
	--if HeroSelection.playerPicks[ event.PlayerID ] == nil then
		HeroSelection.playersPicked = HeroSelection.playersPicked + 1
		HeroSelection.playerPicks[ event.PlayerID ] = event.HeroName

		--Send a pick event to all clients
		CustomGameEventManager:Send_ServerToAllClients( "picking_player_pick",
			{ PlayerID = event.PlayerID, HeroName = event.HeroName } )

		--print("event.PlayerID ",event.PlayerID)
		--print("event.HeroName ",event.HeroName)
	--end

	--[[HeroSelection.playersPicked = HeroSelection.playersPicked + 1
	HeroSelection.playerPicks[ 1 ] = "npc_dota_hero_phantom_assassin"
	CustomGameEventManager:Send_ServerToAllClients( "picking_player_pick",
	{ PlayerID = 1, HeroName = "npc_dota_hero_phantom_assassin" } )]]

	--Check if all heroes have been picked
	if HeroSelection.playersPicked >= HeroSelection.numPickers then

		-- check if any hero duplicates
		local table_players_duplicate = {}
		local table_heroes_duplicate_names = {}
		local count = 0
		for player_id, hero_name in pairs(HeroSelection.playerPicks) do
			for _, hero_name_check in pairs(HeroSelection.playerPicks) do
				if hero_name == hero_name_check then
					count = count + 1
					--print("count ",count)
				end
			end

			if count >= 2 then
				--print("duplicate hero found")
				table.insert(table_players_duplicate,PlayerResource:GetPlayer(player_id))
				table.insert(table_heroes_duplicate_names,hero_name)
				HeroSelection.playersPicked = HeroSelection.playersPicked - 1
				--HeroSelection.playerPicks[ player_id ] = nil
				--print("HeroSelection.playersPicked ",HeroSelection.playersPicked)
			end
			count = 0
		end

		for player_id, hero_name in pairs(HeroSelection.playerPicks) do
			print("player_id: ",player_id,"hero_name ",hero_name)
		end

		-- send an event to clients and reset picking process for those players, when they pick new heroes it should run this check again or end the picking screen
		print("#table_players_duplicate ",#table_players_duplicate)
		if #table_players_duplicate ~= 0 then
			for _, player in pairs(table_players_duplicate) do
				CustomGameEventManager:Send_ServerToPlayer( player, "reset_picks_for_players", { hero_duplicates = table_heroes_duplicate_names} )
			end

			return
		end

		--End picking
		HeroSelection:EndPicking()
	end
end

--[[
	EndPicking
	The final function of hero selection which is called once the selection is done.
	This function spawns the heroes for the players and signals the picking screen
	to disappear.
]]
function HeroSelection:EndPicking()
	--Stop listening to pick events
	--CustomGameEventManager:UnregisterListener( self.listener )

	--Assign the picked heroes to all players that have picked
	for player, hero in pairs( HeroSelection.playerPicks ) do
		HeroSelection:AssignHero( player, hero )
	end

	-- takes time for the assigning to be done 5sec is too long but leave for now
	Timers:CreateTimer(1.0, function()
		--print("how many times does this run")

		--Signal the picking screen to disappear 9also calls other front end things)
		CustomGameEventManager:Send_ServerToAllClients( "picking_done", { } )

		-- use in lua in gamesetup to control other things
		PICKING_DONE = true

		return false
	end)
end

--[[
	AssignHero
	Assign a hero to the player. Replaces the current hero of the player
	with the selected hero, after it has finished precaching.
	Params:
		- player {integer} - The playerID of the player to assign to.
		- hero {string} - The unit name of the hero to assign (e.g. 'npc_dota_hero_rubick')
]]
function HeroSelection:AssignHero( player, hero )
	PrecacheUnitByNameAsync( hero, function()
		PlayerResource:ReplaceHeroWith( player, hero, 0, 0 )
	end, player)
end

