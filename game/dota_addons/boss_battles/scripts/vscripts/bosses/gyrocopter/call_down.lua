call_down = class({})

-- totalDamage because call_down does damage at two different intervals. Each interval applies totalDamage / 2 damage,
local totalDamage = 200

local displayDebug = false

function call_down:OnSpellStart()
	self.cursorPos = self:GetCursorPosition()
	--_G.IsGyroBusy = true

	--spell model:
	local spell_duration = 4
	local tick_interval = 0.1
	local total_ticks = spell_duration / tick_interval
	local current_tick = 0
	local radius = 600

	if displayDebug then
		DebugDrawCircle(self.cursorPos, Vector(255,0,0), 128, radius, true, tick_interval*2) 
	end

	--particles:	
	local p1 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"
	local p2 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf"
	local p3 = "particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf"
	--Initial marker indicator particle
	local p1Index = ParticleManager:CreateParticle(p1, PATTACH_POINT, self:GetCaster())
	ParticleManager:SetParticleControl(p1Index, 0, self.cursorPos)
	ParticleManager:SetParticleControl(p1Index, 1, Vector(radius,radius,-radius))
	ParticleManager:ReleaseParticleIndex( p1Index )
	--first and second explosion particles
	local calldown_first_particle = ParticleManager:CreateParticle(p2, PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(calldown_first_particle, 0, self.cursorPos)
	ParticleManager:SetParticleControl(calldown_first_particle, 1, self.cursorPos)
	ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(calldown_first_particle)
	local calldown_second_particle = ParticleManager:CreateParticle(p3, PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(calldown_second_particle, 0, self.cursorPos)
	ParticleManager:SetParticleControl(calldown_second_particle, 1, self.cursorPos)
	ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(calldown_second_particle)

	--TODO: sounds: 
	--EmitSoundOnClient("gyrocopter_gyro_call_down_05"..RandomInt(1, 2), self:GetCaster():GetPlayerOwner())

	self:GetCaster():EmitSound("gyrocopter_gyro_call_down_05")

	--Start a timer, to deal dmg after x seconds
	Timers:CreateTimer(function()	
		current_tick = current_tick +1

		--half way:
		if current_tick == total_ticks / 2 then 
			local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, self.cursorPos, nil, radius,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
			for _,enemy in pairs(enemies) do
				local damageInfo = 
				{
					victim = enemy, 
					attacker = self:GetCaster(),
					damage = 100, --TODO: calc this / get from somewhere
					damage_type = 4, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
					ability = self,
				}
				local dmgDealt = ApplyDamage(damageInfo)
				if displayDebug then
					DebugDrawCircle(self.cursorPos, Vector(255,0,0), 128, radius, true, tick_interval*2) 
				end
			end
		end
		--last tick:
		if current_tick >= total_ticks then
			local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, self.cursorPos, nil, radius,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
			for _,enemy in pairs(enemies) do
				local damageInfo = 
				{
					victim = enemy, 
					attacker = self:GetCaster(),
					damage = 100, --TODO: calc this / get from somewhere
					damage_type = 4, -- TODO: get this from ability file ... 4 = DAMAGE_TYPE_PURE 
					ability = self,
				}
				local dmgDealt = ApplyDamage(damageInfo)
				if displayDebug then
					DebugDrawCircle(self.cursorPos, Vector(255,0,0), 128, radius, true, tick_interval*2) 
				end
			end
			--_G.IsGyroBusy = false
			return	--stop the timer 
		end
	return tick_interval
	end)

end
