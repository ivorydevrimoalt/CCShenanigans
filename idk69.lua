-- ComputerCraft Lua Script: Raining Rainbow "RAS4" with Shake Effect
-- This script displays "RAS4" raining down in rainbow colors on the computer's
-- internal terminal and then shakes the text when it hits the bottom.
-- No external monitors are required.

-- Get the dimensions of the current terminal.
-- 'width' is the number of columns, 'height' is the number of rows.
local width, height = term.getSize()

-- The text string to be displayed and animated.
local text = "RAS4"
-- Get the length of the text for centering and clearing.
local textLen = string.len(text)

-- Calculate the starting X position to center the text horizontally.
-- math.floor ensures it's an integer.
local startX = math.floor((width - textLen) / 2)

-- Define a table of ComputerCraft color constants to create the rainbow effect.
-- These are standard colors available in ComputerCraft.
local rainbowColors = {
    colors.red,
    colors.orange,
    colors.yellow,
    colors.lime,      -- A bright green
    colors.blue,
    colors.purple,
    colors.magenta
}

-- Helper function to clear a specific area of text on the terminal.
-- This is used to erase the text from its previous position before redrawing,
-- which helps reduce flickering compared to clearing the entire screen.
-- @param x The starting column (X coordinate) to clear from.
-- @param y The row (Y coordinate) to clear.
-- @param len The number of characters (length) to clear.
local function clearText(x, y, len)
    term.setCursorPos(x, y) -- Move cursor to the position where text was.
    term.write(string.rep(" ", len)) -- Overwrite with spaces to clear.
end

-- Main function to run the rain and shake animation.
local function animateRainAndShake()
    -- Initialize the current Y position where the text will be drawn.
    -- We start at 1 (top of the screen).
    local currentY = 1

    -- --- Raining Animation Loop ---
    -- The loop continues as long as the text is within or moving towards the screen height.
    while currentY <= height do
        -- Clear the text from its previous row to create the "raining" effect.
        -- This is only done if the text has moved down from the very top (currentY > 1).
        if currentY > 1 then
            clearText(startX, currentY - 1, textLen)
        end

        -- Calculate the color for the current frame based on the Y position.
        -- The modulo operator (%) cycles through the rainbowColors table.
        local colorIndex = ((currentY - 1) % #rainbowColors) + 1
        term.setTextColour(rainbowColors[colorIndex]) -- Set the text color.

        -- Set the cursor position to draw the text.
        term.setCursorPos(startX, currentY)
        term.write(text) -- Draw the "RAS4" text.

        sleep(0.1) -- Pause for a short duration to control the animation speed.
                   -- A smaller value makes it faster, a larger value makes it slower.

        currentY = currentY + 1 -- Move the text down one row for the next frame.
    end

    -- --- Shake Animation ---
    -- Once the raining animation is complete, the text has "hit the ground".
    -- The groundY is simply the bottom-most row of the terminal.
    local groundY = height

    -- Ensure the text is visible at the ground position before starting the shake.
    -- This handles cases where the last frame of rain might have been just off-screen.
    term.setCursorPos(startX, groundY)
    -- Keep the last rainbow color for the shaking text.
    term.setTextColour(rainbowColors[(groundY - 1) % #rainbowColors + 1])
    term.write(text)

    -- Define how long the shaking effect should last in seconds.
    local shakeDuration = 2
    local startTime = os.clock() -- Record the start time for the shake duration.

    -- Loop to perform the shaking animation for the defined duration.
    while os.clock() - startTime < shakeDuration do
        -- Clear the text from its current (potentially offset) position.
        clearText(startX, groundY, textLen)

        -- Generate small random offsets for the text's position to simulate shaking.
        -- math.random(-1, 1) will give -1, 0, or 1.
        local offsetX = math.random(-1, 1)
        local offsetY = math.random(-1, 1)

        -- Calculate the final position, ensuring it stays within terminal bounds.
        -- math.max(1, ...) prevents going left/up past the edge.
        -- math.min(width - textLen + 1, ...) prevents going right past the edge.
        -- math.min(height, ...) prevents going down past the edge.
        local finalX = math.max(1, math.min(width - textLen + 1, startX + offsetX))
        local finalY = math.max(1, math.min(height, groundY + offsetY))

        term.setCursorPos(finalX, finalY) -- Set the new (shaken) cursor position.
        term.write(text) -- Redraw the text at the new position.

        sleep(0.05) -- Pause for a very short duration to control shake speed.
                    -- A smaller value makes the shake appear faster/more intense.
    end

    -- --- Cleanup After Animation ---
    -- Clear the text from its last shaken position.
    clearText(startX, groundY, textLen)
    -- Restore the text to its original landing spot and reset color to white.
    term.setCursorPos(startX, groundY)
    term.setTextColour(colors.white)
    term.write(text)
end

-- --- Initial Terminal Setup ---
term.clear() -- Clear the entire terminal screen before starting the animation.
term.setTextColour(colors.white) -- Set the default text color to white.

-- --- Run the Animation ---
animateRainAndShake()

-- --- Exit Prompt ---
-- After the animation, display a prompt to the user to exit the script.
term.setCursorPos(1, height) -- Move the cursor to the bottom-left of the screen.
term.setTextColour(colors.lightGray) -- Use a lighter color for the prompt text.
term.write("Press Enter to exit.")
read() -- Wait for the user to press the Enter key. This keeps the program running
       -- until the user explicitly closes it.

-- --- Final Cleanup ---
term.clear() -- Clear the screen one last time when the user exits.
term.setCursorPos(1,1) -- Move cursor to top-left.
term.setTextColour(colors.white) -- Reset text color to white for subsequent programs.
