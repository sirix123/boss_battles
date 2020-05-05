homing_missile = class({})

--Logic based on level:

--lvl 1:
	--Get the players location and moves toward it, exploding upon impact
	--Hits to destroy: 3
	--Same ms as player

--lvl 2:
	--Gets the players location every 2-3 seconds and moves toward it, exploding upon impact
	--Hits to destroy: 5
	--Slightly faster ms than player

--lvl 3:
	--Gets the players location rapidly and moves toward it, exploding upon impact 
	--Hits to destroy: 5
	--Slightly faster ms than player	

--lvl 4:
	--Gets the players location and moves toward it. Checks if any other players are closer, if so it will change targets.
	--Hits to destroy: 5
	--Slightly faster ms than player	

local currentTarget = nil

--todo: DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
function homing_missile:OnSpellStart()
    local caster = self:GetCaster()
    local cursorLoc = self:GetCursorPosition() --should be same as target.GetOrigin()?
	-- gets target for ability
	local target = self:GetCursorTarget()
		--print("bear has aqquired claw target")
 		if target == nil then
 			--print("bear_claw could not get aggro target, getting first available")
 			return
 		end

		local damageInfo = 
		{
			victim = target,
			attacker = self:GetCaster(),
			damage = self.base_damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}

    --Target?

    --Somehow get targe4t? or calculate which target to shoot at?

end


--Function is called each interval/timer tick
--Gets the target/players location and updates the location missile is aiming for
function homing_missile:Tick()


end



function homing_missile:FindNearestEnemy()


end