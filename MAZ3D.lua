-- ComputerCraft 3D Maze Renderer
-- This script creates a simple 3D-like maze experience on a connected monitor.
-- The maze structure is hardcoded, simulating an 'image' input.
-- Navigate using 'W' (forward), 'S' (backward), 'A' (turn left), 'D' (turn right).

-- Configuration
local MONITOR_SIDE = "right" -- Change this to the side your monitor is attached (e.g., "top", "bottom", "left", "right", "front", "back")
local PLAYER_FOV = 60        -- Player's field of view in degrees (affects how wide the view is)
local RENDER_DISTANCE = 10   -- How far the player can 'see' into the maze
local WALL_CHAR = "S"        -- Character for solid walls
local DISTANCE_CHARS = {" ", ".", ":", "=", "#", "X", "@", WALL_CHAR} -- Characters for walls at different distances (closer = denser)

-- Maze Definition (simulating an image input)
-- '#' represents a wall, ' ' represents a path.
-- You can modify this maze to create different layouts.
local maze = {
    "####################",
    "#                  #",
    "# ## # # # ## # ## #",
    "# #  # # # #  # #  #",
    "# # ## # # # ## # ##",
    "# #    # # #    #  #",
    "# # #### # # #### ##",
    "# #      # #       #",
    "# # ####### #######",
    "# # #     # #     #",
    "# # # ### # # ### #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "# # # # # # # # # #",
    "#                  #",
    "####################"
}

-- Convert maze string array to a 2D table for easier access
local function parseMaze(mazeStrings)
    local parsed = {}
    for y, rowStr in ipairs(mazeStrings) do
        parsed[y] = {}
        for x = 1, #rowStr do
            parsed[y][x] = rowStr:sub(x, x)
        end
    end
    return parsed
end

local parsedMaze = parseMaze(maze)
local MAZE_WIDTH = #parsedMaze[1]
local MAZE_HEIGHT = #parsedMaze

-- Player state
local playerX = 2.5 -- Start position (decimal for smoother movement/rotation)
local playerY = 2.5
local playerAngle = 0 -- Angle in degrees (0 = East, 90 = North, 180 = West, 270 = South)

-- Monitor object
local mon
local monWidth, monHeight

-- Function to initialize the monitor
local function initMonitor()
    mon = peripheral.wrap(MONITOR_SIDE)
    if not mon then
        error("No monitor found on side: " .. MONITOR_SIDE .. ". Please attach one.")
    end
    mon.setTextScale(0.5) -- Smaller text scale for more detail
    monWidth, monHeight = mon.getSize()
    mon.clear()
    print("Monitor initialized. Size: " .. monWidth .. "x" .. monHeight)
    print("Use W/S to move, A/D to turn.")
    print("Press Q to quit.")
end

-- Function to get character based on distance
local function getDistanceChar(distance)
    -- Normalize distance to a 0-1 range based on RENDER_DISTANCE
    local normalizedDistance = math.min(distance / RENDER_DISTANCE, 1)
    -- Map normalized distance to an index in DISTANCE_CHARS
    local index = math.floor(normalizedDistance * (#DISTANCE_CHARS - 1)) + 1
    return DISTANCE_CHARS[index]
end

-- Function to draw the 3D-like view on the monitor
local function draw3DView()
    mon.clear()

    -- Calculate player's direction in radians
    local playerRad = math.rad(playerAngle)

    -- Calculate the angle increment for each column on the monitor
    local angleStep = math.rad(PLAYER_FOV) / monWidth

    -- Loop through each column of the monitor
    for col = 0, monWidth - 1 do
        -- Calculate the ray angle for this column
        local rayAngle = playerRad - math.rad(PLAYER_FOV / 2) + (col * angleStep)

        local rayX = playerX
        local rayY = playerY
        local dx = math.cos(rayAngle)
        local dy = math.sin(rayAngle)
        local distance = 0
        local hitWall = false

        -- Cast ray until it hits a wall or exceeds render distance
        while distance < RENDER_DISTANCE and not hitWall do
            rayX = playerX + dx * distance
            rayY = playerY + dy * distance

            local mapX = math.floor(rayX)
            local mapY = math.floor(rayY)

            -- Check if outside maze bounds
            if mapX < 1 or mapX > MAZE_WIDTH or mapY < 1 or mapY > MAZE_HEIGHT then
                break -- Ray went out of bounds
            end

            -- Check if hit a wall
            if parsedMaze[mapY] and parsedMaze[mapY][mapX] == '#' then
                hitWall = true
            end

            distance = distance + 0.1 -- Increment distance in small steps
        end

        -- Determine the height of the wall slice based on distance
        local wallHeight = 0
        if hitWall then
            -- Make closer walls appear taller
            wallHeight = math.floor((1 - (distance / RENDER_DISTANCE)) * monHeight)
            wallHeight = math.max(0, math.min(wallHeight, monHeight)) -- Clamp to monitor height
        end

        -- Get the character for the wall based on its distance
        local charToDraw = getDistanceChar(distance)

        -- Draw the wall slice
        local startY = math.floor((monHeight - wallHeight) / 2)
        for row = 0, monHeight - 1 do
            if row >= startY and row < startY + wallHeight then
                mon.setCursorPos(col + 1, row + 1)
                mon.write(charToDraw)
            else
                -- Draw floor/ceiling (simple background)
                mon.setCursorPos(col + 1, row + 1)
                mon.write(" ")
            end
        end
    end

    -- Display player position for debugging/info
    mon.setCursorPos(1, 1)
    mon.write(string.format("X:%.1f Y:%.1f Ang:%.0f", playerX, playerY, playerAngle))
end

-- Main game loop
local function gameLoop()
    local running = true
    while running do
        draw3DView()

        local event, key = os.pullEvent("key")
        if event == "key" then
            local moveSpeed = 0.5
            local turnSpeed = 15 -- Degrees per turn

            local newPlayerX = playerX
            local newPlayerY = playerY

            if key == keys.w then -- Move forward
                newPlayerX = playerX + math.cos(math.rad(playerAngle)) * moveSpeed
                newPlayerY = playerY + math.sin(math.rad(playerAngle)) * moveSpeed
            elseif key == keys.s then -- Move backward
                newPlayerX = playerX - math.cos(math.rad(playerAngle)) * moveSpeed
                newPlayerY = playerY - math.sin(math.rad(playerAngle)) * moveSpeed
            elseif key == keys.a then -- Turn left
                playerAngle = playerAngle - turnSpeed
            elseif key == keys.d then -- Turn right
                playerAngle = playerAngle + turnSpeed
            elseif key == keys.q then -- Quit
                running = false
            end

            -- Ensure angle stays within 0-360
            playerAngle = playerAngle % 360
            if playerAngle < 0 then playerAngle = playerAngle + 360 end

            -- Collision detection (simple: check if new position is a wall)
            local targetMapX = math.floor(newPlayerX)
            local targetMapY = math.floor(newPlayerY)

            if targetMapX >= 1 and targetMapX <= MAZE_WIDTH and
               targetMapY >= 1 and targetMapY <= MAZE_HEIGHT and
               parsedMaze[targetMapY] and parsedMaze[targetMapY][targetMapX] ~= '#' then
                playerX = newPlayerX
                playerY = newPlayerY
            end
        end
    end
end

-- Run the game
initMonitor()
gameLoop()

mon.clear()
mon.setCursorPos(1, 1)
mon.write("Maze exited. Goodbye!")
