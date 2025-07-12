-- ComputerCraft Lua program to display a sine wave with three tones
-- This script runs directly on the computer's terminal, no external monitor needed.
-- It uses black as the background and different foreground colors for the waves.

-- Get the dimensions of the terminal window.
-- 'width' is the number of columns, 'height' is the number of rows.
local width, height = term.getSize()

-- Define parameters for the sine waves.
-- Amplitude: How high/low the wave goes. Scaled to fit terminal height.
local amplitude = math.floor(height / 3)
-- Frequency 1: Controls the "stretch" of the first wave horizontally.
local frequency1 = 0.15
-- Frequency 2: Controls the "stretch" of the second wave horizontally.
-- Slightly different to make the two waves distinct.
local frequency2 = 0.175
-- Frequency 3: Controls the "stretch" of the third wave horizontally.
-- Added for the new wave.
local frequency3 = 0.2

-- Phase 1: Initial horizontal position of the first wave. Updated for animation.
local phase1 = 0
-- Phase 2: Initial horizontal position of the second wave. Offset for visual variety.
local phase2 = math.pi / 2 -- Offset by 90 degrees (pi/2 radians)
-- Phase 3: Initial horizontal position of the third wave. Another offset for variety.
local phase3 = math.pi -- Offset by 180 degrees (pi radians)

-- Speed: Determines how fast the waves animate. Smaller value means faster.
local speed = 0.1

-- Define the characters and colors for each of the three "tones" (waves).
-- Tone 1: Uses character 'A' and blue color.
local char1 = "A"
local color1 = colors.blue

-- Tone 2: Uses character 'R' and red color.
local char2 = "R"
local color2 = colors.red

-- Tone 3: Uses character 'S' and green color (reusing your existing char0/color0).
local char3 = "S"
local color3 = colors.green

-- Main animation loop. This loop will run indefinitely.
while true do
    -- Clear the entire terminal screen before drawing the new frame.
    term.clear()
    -- Set the background color of the terminal to black.
    term.setBackgroundColor(colors.black)

    -- Iterate through each column (x-coordinate) of the terminal.
    for x = 1, width do
        -- --- Calculate and draw the first sine wave ---
        local y1 = amplitude * math.sin(x * frequency1 + phase1)
        local displayY1 = math.floor(height / 2 + y1)
        if displayY1 < 1 then displayY1 = 1 end
        if displayY1 > height then displayY1 = height end
        term.setTextColor(color1)
        term.setCursorPos(x, displayY1)
        term.write(char1)

        -- --- Calculate and draw the second sine wave ---
        local y2 = amplitude * math.sin(x * frequency2 + phase2)
        local displayY2 = math.floor(height / 2 + y2)
        if displayY2 < 1 then displayY2 = 1 end
        if displayY2 > height then displayY2 = height end
        term.setTextColor(color2)
        term.setCursorPos(x, displayY2)
        term.write(char2)

        -- --- Calculate and draw the third sine wave ---
        -- Calculate the Y position for the third wave.
        local y3 = amplitude * math.sin(x * frequency3 + phase3)
        local displayY3 = math.floor(height / 2 + y3)

        -- Ensure the calculated Y position for the third wave is within bounds.
        if displayY3 < 1 then displayY3 = 1 end
        if displayY3 > height then displayY3 = height end

        -- Set the foreground text color for the third wave.
        term.setTextColor(color3)
        -- Move the cursor to the calculated (x, y) position for the third wave.
        term.setCursorPos(x, displayY3)
        -- Write the character for the third wave.
        term.write(char3)
    end

    -- Update the phase of all waves to create the animation effect.
    -- Each wave moves at a slightly different speed for more dynamic interaction.
    phase1 = phase1 + speed
    phase2 = phase2 + speed * 1.2
    phase3 = phase3 + speed * 0.8 -- New speed for the third wave

    -- Pause for a short duration to control the animation speed.
    -- A smaller value makes the animation faster.
    sleep(0.05)
end
