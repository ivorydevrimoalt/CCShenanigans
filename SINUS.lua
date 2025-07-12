-- ComputerCraft Lua program to display a sine wave with two tones
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
local frequency2 = 0.2
-- Phase 1: Initial horizontal position of the first wave. Updated for animation.
local phase1 = 0
-- Phase 2: Initial horizontal position of the second wave. Offset for visual variety.
local phase2 = math.pi / 2 -- Offset by 90 degrees (pi/2 radians)
-- Speed: Determines how fast the waves animate. Smaller value means faster.
local speed = 0.1

-- Define the characters and colors for each of the two "tones" (waves).
-- Tone 1: Uses a hyphen character and a light blue color.
local char1 = "-"
local color1 = colors.lightBlue

-- Tone 2: Uses a plus character and an orange color.
local char2 = "+"
local color2 = colors.orange

-- Main animation loop. This loop will run indefinitely.
while true do
    -- Clear the entire terminal screen before drawing the new frame.
    term.clear()
    -- Set the background color of the terminal to black.
    term.setBackgroundColor(colors.black)

    -- Iterate through each column (x-coordinate) of the terminal.
    for x = 1, width do
        -- --- Calculate and draw the first sine wave ---

        -- Calculate the Y position for the first wave using the sine function.
        -- The sine function returns values between -1 and 1.
        -- We multiply by amplitude to scale it, and add phase for animation.
        local y1 = amplitude * math.sin(x * frequency1 + phase1)
        -- Convert the calculated Y value to a terminal row.
        -- We add height/2 to center the wave vertically on the screen.
        local displayY1 = math.floor(height / 2 + y1)

        -- Ensure the calculated Y position stays within the terminal's vertical bounds.
        if displayY1 < 1 then displayY1 = 1 end
        if displayY1 > height then displayY1 = height end

        -- Set the foreground text color for the first wave.
        term.setTextColor(color1)
        -- Move the cursor to the calculated (x, y) position.
        term.setCursorPos(x, displayY1)
        -- Write the character for the first wave at the current cursor position.
        term.write(char1)

        -- --- Calculate and draw the second sine wave ---

        -- Calculate the Y position for the second wave, similar to the first.
        local y2 = amplitude * math.sin(x * frequency2 + phase2)
        local displayY2 = math.floor(height / 2 + y2)

        -- Ensure the calculated Y position for the second wave is also within bounds.
        if displayY2 < 1 then displayY2 = 1 end
        if displayY2 > height then displayY2 = height end

        -- Set the foreground text color for the second wave.
        term.setTextColor(color2)
        -- Move the cursor to the calculated (x, y) position for the second wave.
        term.setCursorPos(x, displayY2)
        -- Write the character for the second wave.
        term.write(char2)
    end

    -- Update the phase of both waves to create the animation effect.
    -- The second wave moves at a slightly different speed for more dynamic interaction.
    phase1 = phase1 + speed
    phase2 = phase2 + speed * 1.2

    -- Pause for a short duration to control the animation speed.
    -- A smaller value makes the animation faster.
    sleep(0.05)
end
