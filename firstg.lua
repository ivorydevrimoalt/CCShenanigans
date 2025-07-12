-- Get the primary monitor attached to the computer.
-- If you have multiple monitors, you might need to specify which one,
-- e.g., `peripheral.wrap("right")` or `peripheral.wrap("monitor_0")`.
local monitor = peripheral.wrap("top") -- Change "top" to the side your monitor is on (e.g., "left", "right", "front", "back", "bottom")

-- Check if a monitor was found
if not monitor then
    print("Error: No monitor found. Please ensure a monitor is connected to the specified side.")
    return
end

-- Get monitor dimensions
local width, height = monitor.getSize()

-- Define ComputerCraft color constants for a rainbow effect
local colors = {
    colors.red,
    colors.orange, -- Orange is not a direct CC color, but we can simulate with yellow/brown or just skip
    colors.yellow,
    colors.lime,
    colors.lightBlue,
    colors.blue,
    colors.purple
}

local text_to_display = "RAS4"
local text_length = #text_to_display

-- Function to draw the rainbow text at a specific position
-- x: starting x-coordinate
-- y: starting y-coordinate
-- text: the string to draw
-- colors_table: a table of color constants to cycle through
local function drawRainbowText(x, y, text, colors_table)
    local color_index = 1
    for i = 1, #text do
        local char = text:sub(i, i)
        local color = colors_table[color_index]

        monitor.setTextColour(color)
        monitor.setCursorPos(x + i - 1, y)
        monitor.write(char)

        color_index = color_index + 1
        if color_index > #colors_table then
            color_index = 1 -- Cycle back to the first color
        end
    end
end

-- Function to clear a specific line (useful for animation)
local function clearLine(y)
    monitor.setCursorPos(1, y)
    monitor.write(string.rep(" ", width)) -- Write spaces to clear the line
end

-- Main animation loop
local function animateRain()
    monitor.clear()
    monitor.setBackgroundColour(colors.black)
    monitor.setTextColour(colors.white) -- Reset text color for general messages

    local rain_speed = 0.08 -- Delay between each step of the rain (in seconds)
    local shake_duration = 0.05 -- Delay between each shake movement
    local shake_intensity = 1 -- Max offset for shaking (1 means 1 character unit)
    local num_shakes = 15 -- How many times it shakes

    -- Calculate initial horizontal position to center the text
    local start_x = math.floor((width - text_length) / 2)

    -- Rain down animation
    for y_pos = 1, height - 1 do -- Stop one line before the bottom for the "hit" effect
        monitor.clear() -- Clear the entire screen for smooth movement
        drawRainbowText(start_x, y_pos, text_to_display, colors)
        sleep(rain_speed)
    end

    -- Text has hit the ground, now shake!
    local final_y = height -- The line where the text settles

    -- Shake effect
    for i = 1, num_shakes do
        local offset_x = math.random(-shake_intensity, shake_intensity)
        local offset_y = math.random(-shake_intensity, shake_intensity)

        -- Ensure offsets don't push text off screen
        local current_x = math.max(1, math.min(width - text_length + 1, start_x + offset_x))
        local current_y = math.max(1, math.min(height, final_y + offset_y))

        monitor.clear()
        drawRainbowText(current_x, current_y, text_to_display, colors)
        sleep(shake_duration)
    end

    -- Settle the text at the bottom
    monitor.clear()
    drawRainbowText(start_x, final_y, text_to_display, colors)
    monitor.setCursorPos(1, 1) -- Move cursor away from the text
    monitor.setTextColour(colors.white) -- Reset text color
    print("Text settled. Press Ctrl+T to stop.")

    -- Keep the script running until terminated by user
    while true do
        local event, p1, p2, p3, p4, p5 = os.pullEvent()
        if event == "terminate" then
            break
        end
        sleep(0.1) -- Small sleep to prevent busy-waiting
    end

    monitor.clear() -- Clear monitor on exit
    monitor.setBackgroundColour(colors.black)
    monitor.setTextColour(colors.white)
end

-- Start the animation
animateRain()
