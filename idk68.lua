-- shitwave.lua
-- A chaotic text animation for ComputerCraft.

-- Get the terminal API
local t = term

-- Get the screen dimensions
local width, height = t.getSize()

-- Function to generate a random color
-- ComputerCraft colors are represented by numbers (e.g., colors.white, colors.black, etc.)
-- We'll pick from a common set of colors.
local function getRandomColor()
    local colorsTable = {
        colors.white, colors.orange, colors.magenta, colors.lightBlue,
        colors.yellow, colors.lime, colors.pink, colors.gray,
        colors.lightGray, colors.cyan, colors.purple, colors.blue,
        colors.brown, colors.green, colors.red, colors.black
    }
    return colorsTable[math.random(1, #colorsTable)]
end

-- Function to generate a random character
local function getRandomChar()
    -- ASCII characters from 33 (exclamation mark) to 126 (tilde)
    return string.char(math.random(33, 126))
end

-- Main loop for the "shitwave" animation
while true do
    -- Clear the screen for a fresh wave
    t.clear()

    -- Fill the screen with random characters and colors
    for y = 1, height do
        t.setCursorPos(1, y) -- Set cursor to the beginning of the current row
        for x = 1, width do
            t.setBackgroundColor(getRandomColor()) -- Set random background color
            t.setTextColor(getRandomColor())     -- Set random text color
            t.write(getRandomChar())             -- Write a random character
        end
    end

    -- Small delay before the next wave appears
    sleep(0.05) -- Adjust this value to change the speed of the wave (e.g., 0.1 for slower, 0.01 for faster)
end
