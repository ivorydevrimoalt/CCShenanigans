-- Configuration
local DELAY = 0.05 -- Smaller values make it faster, larger values make it slower
local ROTATION_SPEED = 5 -- Degrees per frame for background rotation
local ZOOM_SPEED = 0.01 -- How fast the zoom changes
local MIN_ZOOM = 0.5    -- Minimum text scale
local MAX_ZOOM = 2.0    -- Maximum text scale
local TEXT_CHARACTERS = {"R", "A", "S", "4"} -- Random characters to paste
local TEXT_COUNT = 5 -- How many random characters to paste per frame

-- Waving text configuration
local WAVING_TEXT = "ivorydevrimo"
local WAVE_AMPLITUDE = 3 -- How high/low the wave goes (in terminal rows)
local WAVE_SPEED = 0.2 -- How fast the wave moves horizontally per character
local WAVE_PHASE_SPEED = 0.1 -- How fast the entire wave animation progresses

-- Initialize terminal
term.clear()
term.setCursorBlink(false) -- Turn off blinking cursor for a cleaner look

local width, height = term.getSize()

-- Check if setTextScale is available, otherwise default zoom to 1
local supportsSetTextScale = type(term.setTextScale) == "function"
if not supportsSetTextScale then
    -- print("Warning: setTextScale not supported. Zoom effect will be disabled.")
    -- sleep(2) -- Commented out to avoid pause if user wants clean run
end

-- Function to convert HSL to a ComputerCraft color
local function hslToCCColor(h, s, l)
    if h >= 0 and h < 60 then return colors.red
    elseif h >= 60 and h < 120 then return colors.yellow
    elseif h >= 120 and h < 180 then return colors.green
    elseif h >= 180 and h < 240 then return colors.cyan
    elseif h >= 240 and h < 300 then return colors.blue
    else return colors.magenta
    end
end

-- Animation state variables
local hue = 0
local currentRotation = 0 -- Current rotation angle in degrees
local currentZoom = 1.0   -- Current text scale for zoom
local zoomDirection = 1   -- 1 for zooming in, -1 for zooming out
local wavePhase = 0       -- Current phase for the waving text

-- Main animation loop
while true do
    -- Clear the screen for each frame
    term.clear()

    -- Update rotation and zoom
    currentRotation = (currentRotation + ROTATION_SPEED) % 360

    if supportsSetTextScale then
        currentZoom = currentZoom + (zoomDirection * ZOOM_SPEED)
        if currentZoom > MAX_ZOOM then
            currentZoom = MAX_ZOOM
            zoomDirection = -1
        elseif currentZoom < MIN_ZOOM then
            currentZoom = MIN_ZOOM
            zoomDirection = 1
        end
        term.setTextScale(currentZoom)
        -- Recalculate width/height as they change with text scale
        width, height = term.getSize()
    end

    -- Calculate center for rotation
    local centerX = width / 2
    local centerY = height / 2

    -- Convert rotation to radians
    local radRotation = math.rad(currentRotation)
    local cosRot = math.cos(radRotation)
    local sinRot = math.sin(radRotation)

    -- Draw the rotating and zooming rainbow background
    for y = 1, height do
        for x = 1, width do
            -- Translate to origin, rotate, translate back
            local translatedX = x - centerX
            local translatedY = y - centerY

            local rotatedX = translatedX * cosRot - translatedY * sinRot
            local rotatedY = translatedX * sinRot + translatedY * cosRot

            local originalX = rotatedX + centerX
            local originalY = rotatedY + centerY

            -- Ensure coordinates are within bounds for hue calculation
            local hueX = math.floor(originalX)
            local hueY = math.floor(originalY)

            -- Calculate a hue based on rotated position and current animation phase
            local currentHue = (hue + (hueX * 2) + (hueY * 5)) % 360
            local color = hslToCCColor(currentHue, 1, 0.5)

            term.setBackgroundColor(color)
            term.setCursorPos(x, y)
            term.write(" ")
        end
    end

    -- Draw random "R A S 4" characters
    for i = 1, TEXT_COUNT do
        local randX = math.random(1, width)
        local randY = math.random(1, height)
        local randChar = TEXT_CHARACTERS[math.random(1, #TEXT_CHARACTERS)]

        -- Set a contrasting text color (e.g., white or black)
        term.setTextColor(colors.white)
        term.setCursorPos(randX, randY)
        term.write(randChar)
    end

    -- Draw the waving "ivorydevrimo" text
    local textLength = #WAVING_TEXT
    local startX = math.floor(width / 2 - textLength / 2) -- Center the text horizontally
    local baseY = math.floor(height / 2) -- Base vertical center

    term.setTextColor(colors.black) -- Set text color for the waving text

    for i = 1, textLength do
        local char = string.sub(WAVING_TEXT, i, i)
        -- Calculate vertical offset using sine wave
        local yOffset = math.sin(wavePhase + (i * WAVE_SPEED)) * WAVE_AMPLITUDE
        local drawY = math.floor(baseY + yOffset)

        -- Ensure drawing within screen bounds
        if drawY < 1 then drawY = 1 end
        if drawY > height then drawY = height end

        term.setCursorPos(startX + i - 1, drawY)
        term.write(char)
    end

    -- Update waving text phase
    wavePhase = wavePhase + WAVE_PHASE_SPEED

    -- Increment hue for the next frame, wrapping around at 360
    hue = (hue + 10) % 360

    sleep(DELAY) -- Pause for a short duration
end
