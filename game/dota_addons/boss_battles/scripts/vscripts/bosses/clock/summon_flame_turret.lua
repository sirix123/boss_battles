summon_flame_turret = class({})
LinkLuaModifier( "summone_flame_turret_thinker", "bosses/clock/modifiers/summone_flame_turret_thinker", LUA_MODIFIER_MOTION_NONE )

function summon_flame_turret:OnSpellStart()
	-- number of cast locations per cast, level up every phase?
    self.numberOfTurretsToSpawn = self:GetSpecialValueFor( "number_of_turrets_to_spawn" )

	-- init
	local caster = self:GetCaster()
	local delay = 2

    local tPositions = {}

    -- logic to do the map magic
    -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
    local point_1 = Vector(-3717,3010,162)
    local point_2 = Vector(-810,3010,256)
    local point_3 = Vector(-3717,212,256)
    local point_4 = Vector(-810,212,256)

    --[[

    DEBUG VECTOR LOCATION: 	Vector 00000000002FA200 [-2197.503174 3053.851807 162.568359] top
    DEBUG VECTOR LOCATION: 	Vector 00000000003ACF80 [-835.743347 1772.583740 162.568359] right
    DEBUG VECTOR LOCATION: 	Vector 00000000004350F8 [-2080.256348 272.832611 162.568359] bottom
    DEBUG VECTOR LOCATION: 	Vector 00000000003D2CF0 [-3708.305908 1663.500366 162.568359] left

    ]]

    self.vNewPositionX = 0
    self.vNewPositionY = 0
    self.direction_x = 0
    self.direction_y = 0
    self.nLine = 0

    -- pick a random line on the box
    -- nline 1 = top of box, 2 = left side, 3 = bottom, 4 = right side
    self.top = 1
    self.left = 2
    self.bottom = 3
    self.right = 4
    --print("self.numberOfTurretsToSpawn ",self.numberOfTurretsToSpawn)
    for i = 1, self.numberOfTurretsToSpawn, 1 do
        --print("i ",i)
        self.nLine = RandomInt(1,4)
        if self.nLine == self.top then
            self.vNewPositionX = RandomInt(point_1.x, point_2.x)
            self.vNewPositionY = point_1.y
            self.direction_x = 0
            self.direction_y = -1
        elseif self.nLine == self.left then
            self.vNewPositionX = point_1.x
            self.vNewPositionY = RandomInt(point_3.y, point_1.y)
            self.direction_x = 1
            self.direction_y = 0
        elseif self.nLine == self.bottom then
            self.vNewPositionX = RandomInt(point_1.x, point_2.x)
            self.vNewPositionY = point_3.y
            self.direction_x = 0
            self.direction_y = 1
        elseif self.nLine == self.right then
            self.vNewPositionX = point_2.x
            self.vNewPositionY = RandomInt(point_3.y, point_1.y)
            self.direction_x = -1
            self.direction_y = 0
        end

        local tSpawnInfo = {
            spawnLocation = Vector(self.vNewPositionX, self.vNewPositionY, 256),
            direction_x = self.direction_x,
            direction_y = self.direction_y
        }

        table.insert(tPositions, tSpawnInfo)
    end

    local j = 0
    for k, tSpawnInfo in pairs(tPositions) do
        --DebugDrawCircle(v, Vector(0,0,255), 128, 50, true, 60)
        Timers:CreateTimer(0.1, function()

            if j == #tPositions then
                return false
            end

            CreateModifierThinker(
                    caster,
                    self,
                    "summone_flame_turret_thinker",
                    { 
                        duration = delay,
                        direction_x = tSpawnInfo.direction_x,
                        direction_y = tSpawnInfo.direction_y
                    },
                    tSpawnInfo.spawnLocation,
                    caster:GetTeamNumber(),
                    false
                )

            table.remove(tSpawnInfo, k)

        end)
    end
end

