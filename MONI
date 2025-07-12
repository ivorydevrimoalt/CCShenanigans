-- ComputerCraft Monitor Rainbow Animation Script
-- This script will find all connected monitors, and for each monitor:
-- 1. Display the text "Ranged" in the center.
-- 2. The "Ranged" text will have a random foreground color.
-- 3. The background will be a continuously animating, rotating rainbow gradient.

-- Global variables and constants
local monitors = {} -- Table to store all found monitor peripherals
-- Define a list of ComputerCraft colors for the rainbow effect.
-- These colors are chosen to create a visually appealing rainbow gradient.
local rainbowColors = {
    colors.red,        -- Bright red
    colors.orange,     -- Vibrant orange
    colors.yellow,     -- Sunny yellow
    colors.lime,       -- Light green
    colors.green,      -- Standard green
    colors.lightBlue,  -- Sky blue
    colors.blue,       -- Deep blue
    colors.purple,     -- Rich purple
    colors.magenta,    -- Bright pink-purple
    colors.pink        -- Soft pink
}

-- Function to get a random ComputerCraft color for the "Ranged" text.
-- This ensures the text color is different each time it's drawn.
function getRandomColor()
    -- All 16 standard ComputerCraft colors are included here for maximum variety.
    local allColors = {
        colors.white, colors.orange, colors.magenta, colors.lightBlue,
        colors.yellow, colors.lime, colors.pink, colors.gray,
        colors.lightGray, colors.cyan, colors.purple, colors.blue,
        colors.brown, colors.green, colors.red, colors.black
    }
    -- Return a random color from the list.
    return allColors[math.random(#allColors)]
end

-- Function to animate a single monitor.
-- This function runs in a separate coroutine for each monitor, allowing
-- multiple monitors to animate concurrently.
function animateMonitor(monitor)
    -- Get the dimensions of the current monitor.
    local width, height = monitor.getSize()
    local frame = 0 -- Counter for animation frames, used to shift the rainbow.

    -- Text to display and its calculated position to be centered.
    local text = "Ranged"
    local textX = math.floor((width - #text) / 2) + 1
    local textY = math.floor(height / 2) + 1

    -- Main animation loop for this monitor.
    while true do
        monitor.clear() -- Clear the monitor before drawing the new frame.

        -- Animate the rotating rainbow background.
        -- We iterate through each row (y-coordinate) of the monitor.
        for y = 1, height do
            -- Calculate the color index for the current row.
            -- The `frame` variable causes the colors to shift (rotate) over time.
            -- The modulo operator (%) ensures the index wraps around the `rainbowColors` table size.
            local colorIndex = ((y + frame - 1) % #rainbowColors) + 1
            -- Set the background color for the current line.
            monitor.setBackgroundColor(rainbowColors[colorIndex])
            -- Move the cursor to the beginning of the current line.
            monitor.setCursorPos(1, y)
            -- Fill the entire line with spaces to apply the background color across the row.
            for x = 1, width do
                monitor.write(" ")
            end
        end

        -- Write the "Ranged" text on top of the background.
        monitor.setTextColor(getRandomColor()) -- Set a random text color.
        monitor.setBackgroundColor(colors.black) -- Set a contrasting background for the text itself.
        monitor.setCursorPos(textX, textY)      -- Position the cursor for the text.
        monitor.write(text)                     -- Write the text.

        frame = frame + 1 -- Increment the frame counter for the next animation step.
        sleep(0.1)        -- Pause for a short duration to control animation speed (0.1 seconds).
    end
end

-- Main program execution starts here.
print("Searching for monitors...")

-- Iterate through all connected peripherals to find monitors.
for _, name in ipairs(peripheral.getNames()) do
    -- Check if the peripheral is a monitor.
    if peripheral.getType(name) == "monitor" then
        -- Wrap the peripheral to get its API functions.
        local monitor = peripheral.wrap(name)
        if monitor then
            table.insert(monitors, monitor) -- Add the found monitor to our list.
            print("Found monitor: " .. name)
        end
    end
end

-- Check if any monitors were found.
if #monitors == 0 then
    print("No monitors found. Please place and connect monitors to your computer.")
else
    print("Starting animation on " .. #monitors .. " monitor(s)...")
    -- For each found monitor, start its animation in a separate coroutine.
    -- This allows all monitors to animate simultaneously without blocking each other.
    for _, monitor in ipairs(monitors) do
        coroutine.resume(coroutine.create(animateMonitor), monitor)
    end
end

-- Keep the main program running indefinitely.
-- This is necessary to allow the coroutines (monitor animations) to continue executing.
while true do
    sleep(1) -- Sleep for 1 second to yield control and prevent high CPU usage.
end
