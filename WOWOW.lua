-- Configuration
local delay = 0.05 -- Delay between frames (lower for faster animation)

-- ComputerCraft terminal colors that approximate a rainbow
-- These are the numerical values for the colors module (e.g., colors.red, colors.orange)
local ccColors = {
    colors.red,
    colors.orange,
    colors.yellow,
    colors.lime,   -- Closest to bright green
    colors.blue,
    colors.purple, -- Closest to indigo
    colors.magenta -- Closest to violet
}

local numCcColors = #ccColors

-- Get all connected monitors
local monitors = {}
for _, side in ipairs(peripheral.getSides()) do
    if peripheral.getType(side) == "monitor" then
        table.insert(monitors, peripheral.wrap(side))
    end
end

if #monitors == 0 then
    error("No monitors found. Please connect one or more monitors.")
end

-- Function to clear a monitor
local function clearMonitor(mon)
    mon.clear()
    mon.setCursorPos(1, 1) -- Reset cursor to top-left
end

-- Function to draw a single frame of the rainbow on all monitors
local function drawRainbowFrame(offset)
    for _, mon in ipairs(monitors) do
        local width, height = mon.getSize()
        clearMonitor(mon) -- Clear before drawing new frame

        -- Iterate through each row and column, setting background color and printing a space
        for y = 1, height do
            for x = 1, width do
                -- Calculate color index, shifting based on 'offset'
                local colorIndex = ((x + offset - 1) % numCcColors) + 1
                local currentColor = ccColors[colorIndex]

                mon.setBackgroundColour(currentColor)
                -- Print a space to fill the character cell with the background color
                mon.write(" ")
            end
            -- Move to the next line after filling a row
            if y < height then
                mon.setCursorPos(1, y + 1)
            end
        end
        mon.setCursorPos(1, 1) -- Reset cursor after drawing frame
    end
end

-- Main animation loop
local offset = 0
while true do
    drawRainbowFrame(offset)
    offset = (offset + 1) % numCcColors
    sleep(delay)
end
