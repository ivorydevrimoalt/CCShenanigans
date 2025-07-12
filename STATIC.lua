-- ComputerCraft Monitor Noise Script
-- This script will find all connected monitors and display a random black and white noise pattern on them.

-- Seed the random number generator for truly random patterns each time the script runs
math.randomseed(os.time())

-- Function to find and initialize monitors
local function initializeMonitors()
    local monitors = {}
    print("Searching for connected peripherals...")
    -- Iterate through all connected peripherals
    for _, peripheralName in ipairs(peripheral.getNames()) do
        if peripheral.getType(peripheralName) == "monitor" then
            local monitor = peripheral.wrap(peripheralName)
            if monitor then
                table.insert(monitors, monitor)
                print("Found monitor: " .. peripheralName)
            end
        end
    end

    if #monitors == 0 then
        print("No external monitors found. Displaying noise on this computer's screen.")
        -- If no external monitors, use the main terminal (computer screen) as the display target
        return {term}
    else
        return monitors
    end
end

-- Main function to display noise on monitors
local function displayNoise(displayTargets)
    if not displayTargets then return end

    -- Loop indefinitely to keep the noise effect running
    while true do
        for _, target in ipairs(displayTargets) do
            -- Get target dimensions (can be monitor or term)
            local width, height = target.getSize()

            -- Clear the target before drawing new noise
            target.clear()

            -- Generate and display random black/white "pixels" using background colors
            for y = 1, height do
                for x = 1, width do
                    -- Move cursor to the current position
                    target.setCursorPos(x, y)
                    -- Set text color to black (ensures no white character pixels interfere)
                    target.setTextColour(colors.black)
                    -- Randomly choose between black or white background for the current "pixel"
                    if math.random(0, 1) == 0 then
                        target.setBackgroundColour(colors.black)
                    else
                        target.setBackgroundColour(colors.white)
                    end
                    -- Print a space character; its background will be the chosen color
                    target.write(" ")
                end
            end
        end
        -- Add a small delay to make the noise visible and prevent excessive CPU usage
        sleep(0.05) -- Adjust this value for faster/slower noise
    end
end

-- Main program execution
local displayTargets = initializeMonitors()

-- Clear the main computer terminal after initial messages
term.clear()
term.setCursorPos(1, 1)

-- Provide a message indicating where the noise is being displayed
if #displayTargets > 0 and displayTargets[1] == term then
    print("Noise display active on this computer's screen. Press Ctrl+T to terminate.")
else
    print("Noise display active on external monitors. Press Ctrl+T to terminate.")
end

-- Start displaying noise on the determined targets
displayNoise(displayTargets)
