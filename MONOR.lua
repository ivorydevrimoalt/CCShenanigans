-- ComputerCraft Monitor Noise Script
-- This script will find all connected monitors and display a random black and white noise pattern on them.

-- Function to find and initialize monitors
local function initializeMonitors()
    local monitors = {}
    print("Searching for connected monitors...")
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
        print("No monitors found. Please ensure monitors are placed and connected.")
        return nil
    else
        return monitors
    end
end

-- Main function to display noise on monitors
local function displayNoise(monitors)
    if not monitors then return end

    -- Loop indefinitely to keep the noise effect running
    while true do
        for _, monitor in ipairs(monitors) do
            -- Get monitor dimensions
            local width, height = monitor.getSize()

            -- Clear the monitor before drawing new noise
            monitor.clear()

            -- Generate and display random black/white "pixels" using background colors
            for y = 1, height do
                for x = 1, width do
                    -- Move cursor to the current position
                    monitor.setCursorPos(x, y)
                    -- Randomly choose between black or white background for the current "pixel"
                    if math.random(0, 1) == 0 then
                        monitor.setBackgroundColour(colors.black)
                    else
                        monitor.setBackgroundColour(colors.white)
                    end
                    -- Print a space character; its background will be the chosen color
                    monitor.write(" ")
                end
            end
        end
        -- Add a small delay to make the noise visible and prevent excessive CPU usage
        sleep(0.005) -- Adjust this value for faster/slower noise
    end
end

-- Main program execution
local connectedMonitors = initializeMonitors()
if connectedMonitors then
    print("Starting noise display. Press Ctrl+T to terminate the script.")
    displayNoise(connectedMonitors)
else
    print("Exiting. No monitors to display on.")
end
