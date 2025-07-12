-- Configuration
local MONITOR_SIDE = "right" -- Change this to the side your monitor is on (e.g., "front", "right", "left", "back", "top", "bottom")
local DELAY = 0.05           -- Smaller values make it faster, larger values make it slower

-- Get the monitor peripheral
local monitor = peripheral.wrap(MONITOR_SIDE)

if not monitor then
    error("No monitor found on the " .. MONITOR_SIDE .. " side. Please check MONITOR_SIDE configuration.")
end

-- Clear the monitor and set initial state
monitor.clear()
monitor.setTextScale(1) -- Set text scale to default

local width, height = monitor.getSize()

-- Function to convert HSL to a ComputerCraft color (0-F)
-- HSL values are typically: h (0-360), s (0-1), l (0-1)
-- ComputerCraft colors are an odd hexadecimal representation
-- This approximation uses a lookup table for common CC colors
-- For a truly smooth rainbow, you'd need a more complex HSL to RGB to CC color conversion,
-- or use the `term.setPaletteColor` function if available (only on advanced monitors/APIs)
local function hslToCCColor(h, s, l)
    -- Simple approximation for CC colors.
    -- A true HSL->RGB->CC color conversion is more complex.
    -- For visual smoothness, we'll map hue directly to CC's limited palette.
    if h >= 0 and h < 60 then return colors.red    -- Red to Yellow
    elseif h >= 60 and h < 120 then return colors.yellow -- Yellow to Green
    elseif h >= 120 and h < 180 then return colors.green  -- Green to Cyan
    elseif h >= 180 and h < 240 then return colors.cyan   -- Cyan to Blue
    elseif h >= 240 and h < 300 then return colors.blue   -- Blue to Magenta
    else return colors.magenta -- Magenta to Red
    end
end

-- Main rainbow animation loop
local hue = 0
while true do
    for y = 1, height do
        for x = 1, width do
            -- Calculate a hue based on position and current animation phase
            -- This creates a "shifting" effect across the screen
            local currentHue = (hue + (x * 2) + (y * 5)) % 360
            local color = hslToCCColor(currentHue, 1, 0.5) -- Full saturation, medium lightness

            monitor.setBackgroundColor(color)
            monitor.setCursorPos(x, y)
            monitor.write(" ") -- Draw a single colored space
        end
    end

    -- Increment hue for the next frame, wrapping around at 360
    hue = (hue + 10) % 360 -- Adjust '10' for faster/slower color cycling

    sleep(DELAY) -- Pause for a short duration
end
