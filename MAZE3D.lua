-- ComputerCraft 3D Maze Raycasting Game
-- This script renders a simple 3D maze view on both the computer's terminal
-- and a connected monitor using raycasting.
-- Navigate with W, A, S, D keys. Press ESC to exit.

-- Maze definition:
-- 0 represents a path (empty space)
-- 1 represents a wall
-- This acts as our "image" for the maze layout.
local maze = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1},
    {1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
    {1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1},
    {1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,1,1,1,1,1,1,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,0,0,0,0,0,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,1,1,1,1,0,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,1,0,1,1,0,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,1,0,0,0,0,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,1,1,1,1,1,1,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1},
    {1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0,1},
    {1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
    {1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

-- Player position and direction
local playerX = 1.5 -- Starting X coordinate (float for smooth movement)
local playerY = 1.5 -- Starting Y coordinate (float for smooth movement)
local playerDirX = -1.0 -- Initial direction vector (looking left along X-axis)
local playerDirY = 0.0

-- Camera plane (perpendicular to player direction, determines FOV)
-- 0.66 gives roughly a 60-degree field of view
local planeX = 0.0
local planeY = 0.66

-- Game state flag
local running = true

-- Attempt to find a connected monitor peripheral
local monitor = peripheral.find("monitor")
if not monitor then
    print("No monitor found! Please ensure a monitor is connected to your ComputerCraft computer.")
    print("Exiting program.")
    return -- Exit if no monitor is found
end

-- Get dimensions of the main terminal and the monitor
local screenWidth = term.getWidth()
local screenHeight = term.getHeight()
local monitorWidth = monitor.getWidth()
local monitorHeight = monitor.getHeight()

-- Function to clear a given screen (either term or monitor)
-- target: The screen object (term or monitor) to clear.
local function clearScreen(target)
    target.clear() -- Clears the entire screen
    target.setCursorPos(1, 1) -- Resets cursor to top-left
end

-- Function to draw a vertical column on a screen
-- This simulates a "pixel" column in our raycasting renderer.
-- x: The column index on the screen (1 to targetWidth).
-- drawStart: The starting row for the wall segment.
-- drawEnd: The ending row for the wall segment.
-- color: The ComputerCraft color constant for the wall segment.
-- target: The screen object (term or monitor) to draw on.
-- targetHeight: The total height of the target screen.
local function drawColumn(x, drawStart, drawEnd, color, target, targetHeight)
    -- Set cursor to the top of the current column
    target.setCursorPos(x, 1)
    for y = 1, targetHeight do
        -- Check if the current row is within the wall segment
        if y >= drawStart and y <= drawEnd then
            target.setBackgroundColor(color) -- Set background color for the wall
        else
            target.setBackgroundColor(colors.black) -- Set background for floor/ceiling
        end
        target.write(" ") -- Write a space to fill the cell with the background color
        -- Move cursor to the next row in the same column
        -- This is crucial as `write(" ")` moves the cursor to the right.
        target.setCursorPos(x, y + 1)
    end
    -- Reset background color after drawing the column for safety
    target.setBackgroundColor(colors.black)
end

-- Function to render the 3D view using raycasting
-- target: The screen object (term or monitor) to render on.
-- targetWidth: The width of the target screen.
-- targetHeight: The height of the target screen.
local function render(target, targetWidth, targetHeight)
    clearScreen(target) -- Clear the screen before drawing a new frame

    -- Loop through each column of the screen
    for x = 1, targetWidth do
        -- Calculate ray position and direction for the current screen column
        -- cameraX maps the screen column to a camera plane coordinate (-1 to 1)
        local cameraX = 2 * x / targetWidth - 1
        local rayDirX = playerDirX + planeX * cameraX
        local rayDirY = playerDirY + planeY * cameraX

        -- Current map cell coordinates the ray is in
        local mapX = math.floor(playerX)
        local mapY = math.floor(playerY)

        -- Length of ray from current position to next x or y-side
        local sideDistX
        local sideDistY

        -- Length of ray from one x or y-side to the next x or y-side
        -- Using 1e30 for division by zero to represent infinity
        local deltaDistX = (rayDirX == 0) and 1e30 or math.abs(1 / rayDirX)
        local deltaDistY = (rayDirY == 0) and 1e30 or math.abs(1 / rayDirY)
        local perpWallDist -- Perpendicular distance from camera to wall

        -- Determine step direction (either +1 or -1) and initial sideDist
        local stepX
        local stepY
        local hit = false -- Flag to check if a wall was hit
        local side -- Which side of the wall was hit (0 for X-side, 1 for Y-side)

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

        -- Digital Differential Analyzer (DDA) loop to find wall intersection
        while not hit do
            -- Move to the next map square, either in X or Y direction
            if sideDistX < sideDistY then
                sideDistX = sideDistX + deltaDistX
                mapX = mapX + stepX
                side = 0 -- X-side wall hit
            else
                sideDistY = sideDistY + deltaDistY
                mapY = mapY + stepY
                side = 1 -- Y-side wall hit
            end

            -- Check if the current map square is a wall
            -- Ensure mapX and mapY are within maze bounds
            if mapY >= 1 and mapY <= #maze and mapX >= 1 and mapX <= #maze[1] then
                if maze[mapY][mapX] == 1 then
                    hit = true
                end
            else
                -- Ray went out of maze bounds, treat as hit to avoid infinite loop
                hit = true
                perpWallDist = 1e30 -- Set a very large distance
            end
        end

        -- Calculate perpendicular distance to the wall
        -- This prevents fisheye distortion
        if side == 0 then -- X-side wall
            perpWallDist = (mapX - playerX + (1 - stepX) / 2) / rayDirX
        else -- Y-side wall
            perpWallDist = (mapY - playerY + (1 - stepY) / 2) / rayDirY
        end

        -- Calculate height of the wall slice to draw on screen
        local lineHeight = math.floor(targetHeight / perpWallDist)

        -- Calculate the starting and ending pixel for the wall slice
        local drawStart = math.floor(-lineHeight / 2 + targetHeight / 2)
        if drawStart < 1 then drawStart = 1 end -- Clamp to top of screen
        local drawEnd = math.floor(lineHeight / 2 + targetHeight / 2)
        if drawEnd >= targetHeight then drawEnd = targetHeight end -- Clamp to bottom of screen

        -- Determine wall color based on side hit and distance for shading
        local wallColor = colors.white -- Default for closest walls

        -- Apply side shading: Y-side walls are slightly darker
        if side == 1 then
            wallColor = colors.lightGray
        end

        -- Apply distance shading: walls further away are darker
        if perpWallDist > 3 then
            if side == 0 then wallColor = colors.gray else wallColor = colors.silver end
        end
        if perpWallDist > 6 then
            if side == 0 then wallColor = colors.silver else wallColor = colors.darkGray end
        end
        -- If very far, make it black (blends with floor/ceiling)
        if perpWallDist > 9 then
            wallColor = colors.black
        end

        -- Draw the calculated column on the target screen
        drawColumn(x, drawStart, drawEnd, wallColor, target, targetHeight)
    end
end

-- Game loop
while running do
    -- Render the maze on the main terminal
    render(term, screenWidth, screenHeight)

    -- Render the maze on the connected monitor
    render(monitor, monitorWidth, monitorHeight)

    -- Handle input events with a timeout
    -- This allows continuous rendering even if no key is pressed.
    local timeout = 0.05 -- Time to wait for a key press (in seconds)
    local event, key = os.pullEvent("key", timeout)

    -- Movement and rotation speeds
    local moveSpeed = 0.2
    local rotSpeed = 0.1

    -- Process key press if an event occurred
    if event == "key" then
        if key == keys.w then -- Move forward
            local newPlayerX = playerX + playerDirX * moveSpeed
            local newPlayerY = playerY + playerDirY * moveSpeed
            -- Check for collision with walls before moving
            if maze[math.floor(newPlayerY)][math.floor(newPlayerX)] == 0 then
                playerX = newPlayerX
                playerY = newPlayerY
            end
        elseif key == keys.s then -- Move backward
            local newPlayerX = playerX - playerDirX * moveSpeed
            local newPlayerY = playerY - playerDirY * moveSpeed
            if maze[math.floor(newPlayerY)][math.floor(newPlayerX)] == 0 then
                playerX = newPlayerX
                playerY = newPlayerY
            end
        elseif key == keys.a then -- Turn left
            -- Rotate player direction vector
            local oldPlayerDirX = playerDirX
            playerDirX = playerDirX * math.cos(rotSpeed) - playerDirY * math.sin(rotSpeed)
            playerDirY = oldPlayerDirX * math.sin(rotSpeed) + playerDirY * math.cos(rotSpeed)
            -- Rotate camera plane vector
            local oldPlaneX = planeX
            planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed)
            planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed)
        elseif key == keys.d then -- Turn right
            -- Rotate player direction vector
            local oldPlayerDirX = playerDirX
            playerDirX = playerDirX * math.cos(-rotSpeed) - playerDirY * math.sin(-rotSpeed)
            playerDirY = oldPlayerDirX * math.sin(-rotSpeed) + playerDirY * math.cos(-rotSpeed)
            -- Rotate camera plane vector
            local oldPlaneX = planeX
            planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
            planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
        elseif key == keys.escape then -- Exit the game
            running = false
        end
    end
end

-- Clean up screens after the game ends
clearScreen(term)
clearScreen(monitor)
term.setCursorPos(1,1)
term.setTextColors(colors.white)
term.setBackgroundColor(colors.black)
print("Maze game ended. Thanks for playing!")
