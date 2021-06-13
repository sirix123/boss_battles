fire_puddle_modifier = class({})

--------------------------------------------------------------------------------
function fire_puddle_modifier:IsHidden()
	return false
end

function fire_puddle_modifier:GetTexture()
	return "batrider_sticky_napalm"
end

--------------------------------------------------------------------------------
function fire_puddle_modifier:OnCreated(kv)
	self.tick_rate = 0.2
	self.dmg = 10

	if IsServer() then
        self:StartIntervalThink(self.tick_rate)
	end
end

--------------------------------------------------------------------------------
function fire_puddle_modifier:OnIntervalThink()
	if IsServer() then

		--if self:GetParent() == nil then self:Destroy() end

		-- hurt em
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dmg,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			--ability = self:GetAbility(),
		}

		ApplyDamage( self.damageTable )

	end
end

function fire_puddle_modifier:OnDestroy( kv )
	if IsServer() then
		self:StartIntervalThink(-1)
	end
end
