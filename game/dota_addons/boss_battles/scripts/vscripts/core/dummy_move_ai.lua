dummy_move_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:SetContextThink( "DummyThink", DummyThink, 0.5 )

    thisEntity.movePosOne = true

end
--------------------------------------------------------------------------------

function DummyThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end


    if thisEntity.movePosOne == true then
        thisEntity.movePosOne = false
        thisEntity:MoveToPosition(Vector(-879,1309,256))
    end

    if thisEntity.movePosOne == false then
        thisEntity.movePosOne = true
        thisEntity:MoveToPosition(Vector(-879,1009,256))
    end

	return 10
end

