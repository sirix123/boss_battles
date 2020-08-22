dummy_move_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:SetContextThink( "DummyThink", DummyThink, 0.5 )

    thisEntity.movePosOne = 1

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
    
    if thisEntity.movePosOne == 1 then
        --print("trying to move  MOVE 1 again")
        thisEntity.movePosOne = 2
        thisEntity:MoveToPosition(Vector(-114,1165,256))
        return 1
    end

    if thisEntity.movePosOne == 2 then
        --print("trying to move MOVE 2 again")
        thisEntity.movePosOne = 1
        thisEntity:MoveToPosition(Vector(-453,1166,256))
        return 1
    end

	return 0.5
end

