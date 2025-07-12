-- Global Configuration
local DELAY = 0.05 -- Base delay for animations

-- State Management
local currentState = 0
local MAX_STATE = 3 -- 0, 1, 2, 3
local currentKeyWait = false -- Flag to prevent rapid key presses from changing state too fast

-- Terminal setup
term.clear()
term.setCursorBlink(false)
local supportsSetTextScale = type(term.setTextScale) == "function"
local baseWidth, baseHeight = term.getSize() -- Store initial size for consistent scaling

-- Utility Functions (re-used from previous versions)
local function hslToCCColor(h, s, l)
    if h >= 0 and h < 60 then return colors.red
    elseif h >= 60 and h < 120 then return colors.yellow
    elseif h >= 120 and h < 180 then return colors.green
    elseif h >= 180 and h < 240 then return colors.cyan
    elseif h >= 240 and h < 300 then return colors.blue
    else return colors.magenta
    end
end

-- ######################################################################
-- # State 0: Rainbow Waving Text                                     #
-- ######################################################################

-- State 0 Configuration
local RAINBOW_TEXT_CHARACTERS = {"R", "A", "S", "4"}
local RAINBOW_TEXT_COUNT = 5
local WAVING_TEXT = "ivorydevrimo"
local WAVE_AMPLITUDE = 3
local WAVE_SPEED = 0.2
local WAVE_PHASE_SPEED = 0.1

-- State 0 Animation State
local rainbowHue = 0
local rainbowCurrentRotation = 0
local rainbowCurrentZoom = 1.0
local rainbowZoomDirection = 1
local rainbowWavePhase = 0

local function drawState0()
    local width, height = term.getSize() -- Get current size, depends on zoom

    -- Update rotation and zoom
    rainbowCurrentRotation = (rainbowCurrentRotation + 5) % 360 -- ROTATION_SPEED
    if supportsSetTextScale then
        rainbowCurrentZoom = rainbowCurrentZoom + (rainbowZoomDirection * 0.01) -- ZOOM_SPEED
        if rainbowCurrentZoom > 2.0 then -- MAX_ZOOM
            rainbowCurrentZoom = 2.0
            rainbowZoomDirection = -1
        elseif rainbowCurrentZoom < 0.5 then -- MIN_ZOOM
            rainbowCurrentZoom = 0.5
            rainbowZoomDirection = 1
        end
        term.setTextScale(rainbowCurrentZoom)
        width, height = term.getSize() -- Update dimensions after scale
    end

    local centerX = width / 2
    local centerY = height / 2
    local radRotation = math.rad(rainbowCurrentRotation)
    local cosRot = math.cos(radRotation)
    local sinRot = math.sin(radRotation)

    -- Draw rainbow background
    for y = 1, height do
        for x = 1, width do
            local translatedX = x - centerX
            local translatedY = y - centerY
            local rotatedX = translatedX * cosRot - translatedY * sinRot
            local rotatedY = translatedX * sinRot + translatedY * cosRot
            local originalX = rotatedX + centerX
            local originalY = rotatedY + centerY
            local hueX = math.floor(originalX)
            local hueY = math.floor(originalY)
            local currentHue = (rainbowHue + (hueX * 2) + (hueY * 5)) % 360
            term.setBackgroundColor(hslToCCColor(currentHue, 1, 0.5))
            term.setCursorPos(x, y)
            term.write(" ")
        end
    end

    -- Draw random "R A S 4" characters
    for i = 1, RAINBOW_TEXT_COUNT do
        local randX = math.random(1, width)
        local randY = math.random(1, height)
        local randChar = RAINBOW_TEXT_CHARACTERS[math.random(1, #RAINBOW_TEXT_CHARACTERS)]
        term.setTextColor(colors.white)
        term.setCursorPos(randX, randY)
        term.write(randChar)
    end

    -- Draw the waving "ivorydevrimo" text
    local textLength = #WAVING_TEXT
    local startX = math.floor(width / 2 - textLength / 2)
    local baseY = math.floor(height / 2)
    term.setTextColor(colors.black)

    for i = 1, textLength do
        local char = string.sub(WAVING_TEXT, i, i)
        local yOffset = math.sin(rainbowWavePhase + (i * WAVE_SPEED)) * WAVE_AMPLITUDE
        local drawY = math.floor(baseY + yOffset)
        if drawY < 1 then drawY = 1 end
        if drawY > height then drawY = height end
        term.setCursorPos(startX + i - 1, drawY)
        term.write(char)
    end

    rainbowWavePhase = rainbowWavePhase + WAVE_PHASE_SPEED
    rainbowHue = (rainbowHue + 10) % 360
end

-- ######################################################################
-- # State 1: Diagonally Spinning Cube                                #
-- ######################################################################

-- Cube vertices (relative to origin)
local cubeVertices = {
    {-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
    {-1, -1, 1}, {1, -1, 1}, {1, 1, 1}, {-1, 1, 1}
}

-- Cube edges (pairs of vertex indices)
local cubeEdges = {
    {1,2}, {2,3}, {3,4}, {4,1}, -- Front face
    {5,6}, {6,7}, {7,8}, {8,5}, -- Back face
    {1,5}, {2,6}, {3,7}, {4,8}  -- Connecting edges
}

-- State 1 Configuration
local CUBE_SCALE = 5 -- Size of the cube on screen
local CUBE_DISTANCE = 10 -- "Z" distance for perspective (larger = less perspective)
local CUBE_ROT_SPEED_X = 2 -- Degrees per frame
local CUBE_ROT_SPEED_Y = 3
local CUBE_ROT_SPEED_Z = 1

-- State 1 Animation State
local cubeRotX, cubeRotY, cubeRotZ = 0, 0, 0

-- Rotation function (simplified, combined for X, Y, Z for diagonal effect)
local function rotatePoint(x, y, z, rx, ry, rz)
    local radX, radY, radZ = math.rad(rx), math.rad(ry), math.rad(rz)
    local cosX, sinX = math.cos(radX), math.sin(radX)
    local cosY, sinY = math.cos(radY), math.sin(radY)
    local cosZ, sinZ = math.cos(radZ), math.sin(radZ)

    -- Rotate around X
    local y1 = y * cosX - z * sinX
    local z1 = y * sinX + z * cosX
    y, z = y1, z1

    -- Rotate around Y
    local x1 = x * cosY + z * sinY
    local z1 = -x * sinY + z * cosY
    x, z = x1, z1

    -- Rotate around Z
    local x1 = x * cosZ - y * sinZ
    local y1 = x * sinZ + y * cosZ
    x, y = x1, y1

    return x, y, z
end

local function drawState1()
    term.clear()
    term.setBackgroundColor(colors.black) -- Dark background for cube
    term.setTextColor(colors.white)

    local width, height = baseWidth, baseHeight -- Use base size for cube for consistency
    term.setTextScale(1) -- Reset text scale for cube

    cubeRotX = (cubeRotX + CUBE_ROT_SPEED_X) % 360
    cubeRotY = (cubeRotY + CUBE_ROT_SPEED_Y) % 360
    cubeRotZ = (cubeRotZ + CUBE_ROT_SPEED_Z) % 360

    local projectedVertices = {}
    for i, v in ipairs(cubeVertices) do
        local x, y, z = rotatePoint(v[1], v[2], v[3], cubeRotX, cubeRotY, cubeRotZ)

        -- Simple perspective projection
        local perspectiveFactor = CUBE_DISTANCE / (CUBE_DISTANCE + z)
        local projX = x * CUBE_SCALE * perspectiveFactor + width / 2
        local projY = y * CUBE_SCALE * perspectiveFactor + height / 2

        table.insert(projectedVertices, {math.floor(projX), math.floor(projY)})
    end

    -- Draw edges
    for _, edge in ipairs(cubeEdges) do
        local p1 = projectedVertices[edge[1]]
        local p2 = projectedVertices[edge[2]]

        -- Basic line drawing (Bresenham's algorithm approximation)
        local x0, y0 = p1[1], p1[2]
        local x1, y1 = p2[1], p2[2]

        local dx = math.abs(x1 - x0)
        local dy = math.abs(y1 - y0)
        local sx = (x0 < x1) and 1 or -1
        local sy = (y0 < y1) and 1 or -1
        local err = dx - dy

        while true do
            if x0 >= 1 and x0 <= width and y0 >= 1 and y0 <= height then
                term.setCursorPos(x0, y0)
                term.write("#") -- Draw with a character
            end

            if x0 == x1 and y0 == y1 then break end
            local e2 = 2 * err
            if e2 > -dy then err = err - dy; x0 = x0 + sx end
            if e2 < dx then err = err + dx; y0 = y0 + sy end
        end
    end
end

-- ######################################################################
-- # State 2: Deshuffling "ivoman" Text                               #
-- ######################################################################

-- State 2 Configuration
local TARGET_TEXT = "ivoman"
local DESHUFFLE_SPEED = 0.05 -- How fast letters move
local SCRAMBLE_RADIUS = 10 -- Max initial scramble distance
local SCRAMBLE_ANGLE_SPEED = 0.1 -- How fast they spiral in

-- State 2 Animation State
local deshufllePhase = 0
local initialPositions = {}
local targetPositions = {}

local function initializeDeshuffle()
    local width, height = baseWidth, baseHeight
    term.setTextScale(1) -- Reset text scale

    local textLength = #TARGET_TEXT
    local startX = math.floor(width / 2 - textLength / 2)
    local startY = math.floor(height / 2)

    for i = 1, textLength do
        targetPositions[i] = {x = startX + i - 1, y = startY}
        -- Scramble positions randomly around the target
        local randAngle = math.random() * 2 * math.pi
        local randDist = math.random() * SCRAMBLE_RADIUS
        initialPositions[i] = {
            x = math.floor(startX + i - 1 + math.cos(randAngle) * randDist),
            y = math.floor(startY + math.sin(randAngle) * randDist)
        }
    end
    deshufllePhase = 0
end

local function drawState2()
    term.clear()
    term.setBackgroundColor(colors.lightGray) -- Neutral background
    term.setTextColor(colors.blue) -- Blue text

    local width, height = baseWidth, baseHeight -- Use base size
    term.setTextScale(1)

    -- Update phase, clamp to 1 for final position
    deshufllePhase = deshufllePhase + DESHUFFLE_SPEED
    if deshufllePhase > 1 then deshufllePhase = 1 end

    for i = 1, #TARGET_TEXT do
        local char = string.sub(TARGET_TEXT, i, i)
        local initial = initialPositions[i]
        local target = targetPositions[i]

        -- Interpolate position using sinus/cosinus for a curved path (e.g., spiral in)
        -- This isn't strictly necessary for "deshuffling" but fits the request for sinus/cosinus
        local dx = target.x - initial.x
        local dy = target.y - initial.y

        -- Use a circular path that converges
        local currentX = initial.x + dx * deshufllePhase
        local currentY = initial.y + dy * deshufllePhase

        -- Add a spiral component that diminishes
        local spiralRadius = (1 - deshufllePhase) * SCRAMBLE_RADIUS
        local spiralAngle = deshufllePhase * math.pi * 4 + (i * SCRAMBLE_ANGLE_SPEED) -- Spin more as it approaches

        currentX = currentX + math.cos(spiralAngle) * spiralRadius * 0.5
        currentY = currentY + math.sin(spiralAngle) * spiralRadius * 0.5


        -- Clamp to screen bounds
        local drawX = math.max(1, math.min(width, math.floor(currentX)))
        local drawY = math.max(1, math.min(height, math.floor(currentY)))

        term.setCursorPos(drawX, drawY)
        term.write(char)
    end
end

-- ######################################################################
-- # State 3: Pre-defined Text Maze (Image from URL is IMPOSSIBLE)    #
-- ######################################################################

-- State 3 Configuration
-- This maze is pre-defined as a string.
-- A true image-to-maze from URL is NOT possible in ComputerCraft Lua directly.
local MAZE_DATA = {
    "####################",
    "#                  #",
    "# ## # # ## # # ## #",
    "# #  # # #  # # #  #",
    "# # ########## # # #",
    "# #              # #",
    "## ############## ##",
    "# #              # #",
    "# # ## # # ## # # ##",
    "# #  # # #  # # #  #",
    "# # ########## # # #",
    "# #              # #",
    "####################"
}

local function drawState3()
    term.clear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.setTextScale(1) -- Reset text scale

    local mazeWidth = #MAZE_DATA[1]
    local mazeHeight = #MAZE_DATA

    local startX = math.floor(baseWidth / 2 - mazeWidth / 2)
    local startY = math.floor(baseHeight / 2 - mazeHeight / 2)

    for y = 1, mazeHeight do
        local row = MAZE_DATA[y]
        for x = 1, mazeWidth do
            local char = string.sub(row, x, x)
            term.setCursorPos(startX + x - 1, startY + y - 1)
            term.write(char)
        end
    end

    -- Add a small message
    term.setCursorPos(1, baseHeight)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    term.write(" (Press any key for next shenanigans) ")
end

-- ######################################################################
-- # Main Loop and Key Handling                                       #
-- ######################################################################

-- Event loop
while true do
    term.clear() -- Clear always at the start of a frame draw

    if currentState == 0 then
        drawState0()
    elseif currentState == 1 then
        drawState1()
    elseif currentState == 2 then
        drawState2()
    elseif currentState == 3 then
        drawState3()
    end

    sleep(DELAY)

    -- Check for key presses
    local event, key = os.pullEvent("key")
    if event == "key" and not currentKeyWait then
        currentState = (currentState + 1) % (MAX_STATE + 1)
        currentKeyWait = true -- Set flag to true
        -- Re-initialize states as needed
        if currentState == 0 then
            -- Reset rainbow state
            rainbowHue = 0
            rainbowCurrentRotation = 0
            rainbowCurrentZoom = 1.0
            rainbowZoomDirection = 1
            rainbowWavePhase = 0
        elseif currentState == 1 then
            -- Reset cube state
            cubeRotX, cubeRotY, cubeRotZ = 0, 0, 0
        elseif currentState == 2 then
            initializeDeshuffle() -- Scramble letters for new animation
        end
        term.clear() -- Clear immediately on state change
        term.setTextScale(1) -- Reset scale when changing states
    end

    -- Small delay for key press debounce
    if currentKeyWait then
        sleep(0.1) -- Short debounce time
        local _, _, _, isDown = os.pullEvent("key_up")
        if isDown then -- Wait for key to be released
            currentKeyWait = false
        end
    end
end
