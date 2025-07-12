--[[
  ComputerCraft 3D Maze Generator and Renderer

  This script creates a pseudo-3D maze experience on a ComputerCraft monitor
  using a raycasting technique, similar to early 3D games like Wolfenstein 3D.

  The maze layout is defined by a 2D table (the 'maze_map' variable),
  where 0 represents an open path and 1 represents a wall.

  Controls:
  - 'w': Move forward
  - 's': Move backward
  - 'a': Turn left
  - 'd': Turn right

  Important Notes:
  - Direct image fetching from the internet is NOT supported in standard ComputerCraft.
    The maze "image" must be defined within the script.
  - This is a pseudo-3D rendering, not true 3D. Walls are drawn as vertical lines
    of characters, with their height scaled by distance.
  - Performance may vary depending on your ComputerCraft setup and monitor size.
]]

-- === Configuration ===
local MON = peripheral.wrap("top") -- Change "top" to the side your monitor is on (e.g., "right", "left", "front")
local PLAYER_SPEED = 0.2          -- How fast the player moves
local TURN_SPEED = 0.05           -- How fast the player turns (in radians)
local FOV = math.pi / 3           -- Field of View (60 degrees)
local RENDER_DISTANCE = 15        -- Maximum distance to render walls

-- Define your maze "image" here.
-- 0 = path, 1 = wall.
-- Make sure there's a path for the player to start in!
local maze_map = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1},
    {1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

-- Player state
local playerX = 1.5   -- Starting X position (float for smooth movement)
local playerY = 1.5   -- Starting Y position (float for smooth movement)
local playerDir = 0.0 -- Player's direction in radians (0 = East, pi/2 = North, pi = West, 3pi/2 = South)

-- Get monitor dimensions
local monitorWidth, monitorHeight = MON.getSize()

-- === Helper Functions ===

-- Function to draw a vertical line on the monitor
-- x: column on monitor
-- startY: starting row
-- endY: ending row
-- char: character to draw
-- color: background color
local function drawVerticalLine(x, startY, endY, char, color)
    MON.setBackgroundColor(color)
    for y = startY, endY do
        MON.setCursorPos(x, y)
        MON.write(char)
    end
end

-- Function to clear the monitor and draw floor/ceiling
local function clearScreen()
    MON.setBackgroundColor(colors.black)
    MON.clear()
    -- Draw ceiling (light blue)
    MON.setBackgroundColor(colors.lightBlue)
    for y = 1, math.floor(monitorHeight / 2) do
        MON.setCursorPos(1, y)
        MON.write(string.rep(" ", monitorWidth))
    end
    -- Draw floor (gray)
    MON.setBackgroundColor(colors.gray)
    for y = math.ceil(monitorHeight / 2) + 1, monitorHeight do
        MON.setCursorPos(1, y)
        MON.write(string.rep(" ", monitorWidth))
    end
end

-- === Main Rendering Function ===
local function renderMaze()
    clearScreen()

    -- Loop through each column of the monitor
    for x = 1, monitorWidth do
        -- Calculate ray angle for this column
        local cameraX = 2 * (x / monitorWidth) - 1 -- x-coordinate in camera space (-1 to 1)
        local rayDirX = math.cos(playerDir) + math.sin(playerDir) * cameraX
        local rayDirY = math.sin(playerDir) - math.cos(playerDir) * cameraX

        -- Which box of the map we're in
        local mapX = math.floor(playerX)
        local mapY = math.floor(playerY)

        -- Length of ray from current position to next x or y-side
        local sideDistX
        local sideDistY

        -- Length of ray from one x or y-side to the next x or y-side
        local deltaDistX = math.sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
        local deltaDistY = math.sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))
        local perpWallDist -- Perpendicular distance to wall

        -- What direction to step in x or y-direction (either +1 or -1)
        local stepX
        local stepY

        local hit = false -- Was there a wall hit?
        local side    -- Was a North/South wall (0) or East/West wall (1) hit?

        -- Calculate step and initial sideDist
        if rayDirX < 0 then
            stepX = -1
            sideDistX = (playerX - mapX) * deltaDistX
        else
            stepX = 1
            sideDistX = (mapX + 1.0 - playerX) * deltaDistX
        end
        if rayDirY < 0 then
            stepY = -1
            sideDistY = (playerY - mapY) * deltaDistY
        else
            stepY = 1
            sideDistY = (mapY + 1.0 - playerY) * deltaDistY
        end

        -- Perform DDA (Digital Differential Analyzer)
        while not hit and perpWallDist < RENDER_DISTANCE do
            -- Jump to next map square, OR in x-direction, OR in y-direction
            if sideDistX < sideDistY then
                sideDistX = sideDistX + deltaDistX
                mapX = mapX + stepX
                side = 0
            else
                sideDistY = sideDistY + deltaDistY
                mapY = mapY + stepY
                side = 1
            end

            -- Check if ray has hit a wall (check bounds first)
            if mapY >= 1 and mapY <= #maze_map and
               mapX >= 1 and mapX <= #maze_map[mapY] then
                if maze_map[mapY][mapX] == 1 then
                    hit = true
                end
            else
                -- Ray went out of bounds, stop rendering this ray
                hit = true
                perpWallDist = RENDER_DISTANCE + 1 -- Set to beyond render distance
            end
        end

        -- Calculate distance projected on camera direction (Euclidean distance would give fisheye effect)
        if side == 0 then
            perpWallDist = (mapX - playerX + (1 - stepX) / 2) / rayDirX
        else
            perpWallDist = (mapY - playerY + (1 - stepY) / 2) / rayDirY
        end

        -- Only draw if within render distance
        if perpWallDist <= RENDER_DISTANCE then
            -- Calculate height of line to draw on screen
            local lineHeight = math.floor(monitorHeight / perpWallDist)

            -- Calculate lowest and highest pixel to fill current stripe
            local drawStart = math.floor(-lineHeight / 2 + monitorHeight / 2)
            local drawEnd = math.floor(lineHeight / 2 + monitorHeight / 2)

            -- Clamp drawStart and drawEnd to screen bounds
            if drawStart < 1 then drawStart = 1 end
            if drawEnd >= monitorHeight then drawEnd = monitorHeight end

            -- Choose wall color based on side hit (to differentiate walls)
            local wallColor
            if side == 1 then -- Y-side (North/South wall)
                wallColor = colors.orange
            else             -- X-side (East/West wall)
                wallColor = colors.red
            end

            -- Shade walls based on distance for a bit more depth
            local shadeFactor = math.max(0, 1 - (perpWallDist / RENDER_DISTANCE) * 0.7) -- 0.7 makes it darker
            if shadeFactor < 0.3 then shadeFactor = 0.3 end -- Minimum brightness

            -- ComputerCraft doesn't have direct RGB manipulation.
            -- We'll use a simplified shading by picking a darker color for distant walls.
            if perpWallDist > RENDER_DISTANCE * 0.6 then
                if side == 1 then wallColor = colors.brown else wallColor = colors.darkRed end
            elseif perpWallDist > RENDER_DISTANCE * 0.3 then
                if side == 1 then wallColor = colors.orange else wallColor = colors.red end
            else
                if side == 1 then wallColor = colors.yellow else wallColor = colors.lightRed end
            end


            -- Draw the wall slice
            drawVerticalLine(x, drawStart, drawEnd, "█", wallColor) -- Use a block character

            -- Draw floor and ceiling for this column (if not covered by wall)
            MON.setBackgroundColor(colors.lightBlue) -- Ceiling
            for y = 1, drawStart - 1 do
                MON.setCursorPos(x, y)
                MON.write(" ")
            end
            MON.setBackgroundColor(colors.gray) -- Floor
            for y = drawEnd + 1, monitorHeight do
                MON.setCursorPos(x, y)
                MON.write(" ")
            end
        else
            -- If wall is too far, just draw floor/ceiling for this column
            MON.setBackgroundColor(colors.lightBlue)
            for y = 1, math.floor(monitorHeight / 2) do
                MON.setCursorPos(x, y)
                MON.write(" ")
            end
            MON.setBackgroundColor(colors.gray)
            for y = math.ceil(monitorHeight / 2) + 1, monitorHeight do
                MON.setCursorPos(x, y)
                MON.write(" ")
            end
        end
    end

    -- Display player coordinates for debugging (optional)
    MON.setBackgroundColor(colors.black)
    MON.setTextColor(colors.white)
    MON.setCursorPos(1,1)
    MON.write(string.format("X:%.2f Y:%.2f", playerX, playerY))
end

-- === Game Loop ===
local function gameLoop()
    while true do
        renderMaze() -- Draw the current frame

        local event, p1, p2, p3 = os.pullEvent() -- Wait for an event

        if event == "key" then
            if p1 == keys.w then -- Move forward
                local newX = playerX + math.cos(playerDir) * PLAYER_SPEED
                local newY = playerY + math.sin(playerDir) * PLAYER_SPEED
                -- Check for collision before moving
                if maze_map[math.floor(newY)][math.floor(newX)] == 0 then
                    playerX = newX
                    playerY = newY
                end
            elseif p1 == keys.s then -- Move backward
                local newX = playerX - math.cos(playerDir) * PLAYER_SPEED
                local newY = playerY - math.sin(playerDir) * PLAYER_SPEED
                -- Check for collision before moving
                if maze_map[math.floor(newY)][math.floor(newX)] == 0 then
                    playerX = newX
                    playerY = newY
                end
            elseif p1 == keys.a then -- Turn left
                playerDir = playerDir - TURN_SPEED
            elseif p1 == keys.d then -- Turn right
                playerDir = playerDir + TURN_SPEED
            elseif p1 == keys.q then -- Exit
                break
            end
        end
    end
end

-- Initial setup
MON.setTextScale(1) -- Ensure text scale is normal for best rendering
MON.clear()
MON.setCursorPos(1,1)
MON.write("Loading Maze...")
sleep(1) -- Give time for message to display

-- Start the game
gameLoop()

-- Clean up on exit
MON.clear()
MON.setBackgroundColor(colors.black)
MON.setTextColor(colors.white)
MON.setCursorPos(1,1)
MON.write("Maze exited. Thanks for playing!")
