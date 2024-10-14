





-- Function to create lanes with sections and spawn thinkers
function createLanes(numLanes, sectionsPerLane)
    -- Variables to control the size of each section
    local sectionWidth = 100
    local sectionHeight = 50

    -- Table to store the lanes
    local lanes = {}

    -- Loop through the number of lanes
    for laneIndex = 1, numLanes do
        -- Table to store the sections for the current lane
        local lane = {}

        -- Loop through the number of sections per lane
        for sectionIndex = 1, sectionsPerLane do
            -- Calculate the position of the section
            local position = {
                x = (sectionIndex - 1) * sectionWidth,
                y = (laneIndex - 1) * sectionHeight
            }

            -- Create a section with width, height, and position properties
            local section = {
                width = sectionWidth,
                height = sectionHeight,
                position = position
            }

            -- Spawn a section thinker at the section's position
            spawnThinker("sectionThinker", position)

            -- Add the section to the current lane
            table.insert(lane, section)
        end

        -- Calculate the position of the lane thinker (e.g., at the start of the lane)
        local lanePosition = {
            x = 0,
            y = (laneIndex - 1) * sectionHeight
        }

        -- Spawn a lane thinker at the lane's position
        spawnThinker("laneThinker", lanePosition)

        -- Add the lane to the lanes table
        table.insert(lanes, lane)
    end

    -- Return the lanes table
    return lanes
end

-- Dummy function to simulate spawning a thinker
function spawnThinker(thinkerType, position)
    print("Spawning " .. thinkerType .. " at position (" .. position.x .. ", " .. position.y .. ")")
end

-- Example usage
local lanes = createLanes(3, 4)
for i, lane in ipairs(lanes) do
    print("Lane " .. i .. ":")
    for j, section in ipairs(lane) do
        print("  Section " .. j .. " - Width: " .. section.width .. ", Height: " .. section.height .. ", Position: (" .. section.position.x .. ", " .. section.position.y .. ")")
    end
end