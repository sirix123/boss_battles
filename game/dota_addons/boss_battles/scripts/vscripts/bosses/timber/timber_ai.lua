timber = class({})

function Spawn( entityKeyValues )
	print("timber Spawn called")

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:SetContextThink( "Timber", TimberThink, 1 )
end

function TimberThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	print("timber thinking...")

	return 0.5
end



