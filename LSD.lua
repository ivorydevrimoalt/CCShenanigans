local PI = math.pi
local WAVE_SCALE_X = 0.05  -- Adjust for horizontal wave density
local WAVE_SCALE_Y = 0.05  -- Adjust for vertical wave density
local TIME_SCALE = 0.005   -- Adjust for animation speed
local COLOR_INTENSITY = 127.5 -- Half of 255, for mapping sin/cos output to 0-255 range

--- Calculates a rainbow color based on x, y coordinates and time.
-- @param x number The x-coordinate of the pixel.
-- @param y number The y-coordinate of the pixel.
-- @param time number A time value (e.g., os.clock() for animation).
-- @return number The red component (0-255).
-- @return number The green component (0-255).
-- @return number The blue component (0-255).
function get_color(x, y, time)
    -- Combine x, y, and time to create complex wave patterns
    local val1 = x * WAVE_SCALE_X + math.sin(y * WAVE_SCALE_Y + time * TIME_SCALE)
    local val2 = y * WAVE_SCALE_Y + math.cos(x * WAVE_SCALE_X - time * TIME_SCALE)

    -- Use sine and cosine with different phases and frequencies for RGB channels
    -- Map the sine/cosine output (-1 to 1) to the 0-255 color range
    local r = math.floor(math.sin(val1 * 1.0 + time * TIME_SCALE * 0.5) * COLOR_INTENSITY + COLOR_INTENSITY)
    local g = math.floor(math.sin(val2 * 1.2 + time * TIME_SCALE * 0.7 + PI * 2/3) * COLOR_INTENSITY + COLOR_INTENSITY)
    local b = math.floor(math.sin(val1 * 1.4 + time * TIME_SCALE * 0.9 + PI * 4/3) * COLOR_INTENSITY + COLOR_INTENSITY)

    -- Ensure values are within 0-255 range
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))

    return r, g, b
end

-- Example usage (for demonstration, you would replace this with your GDI loop)
-- Imagine a screen of 800x600 pixels
local screen_width = 800
local screen_height = 600

print("--- Simulating Colors for a Grid (0,0 to 799,599) at Time 0 ---")
-- You would typically run this in a loop for animation
local current_time = 0 -- In a real GDI app, this would increment (e.g., os.clock())

-- Example: Get color for a few specific points
local r, g, b = get_color(0, 0, current_time)
print(string.format("Color at (0, 0): R=%d, G=%d, B=%d", r, g, b))

r, g, b = get_color(screen_width / 2, screen_height / 2, current_time)
print(string.format("Color at (%d, %d): R=%d, G=%d, B=%d", screen_width / 2, screen_height / 2, r, g, b))

r, g, b = get_color(screen_width - 1, screen_height - 1, current_time)
print(string.format("Color at (%d, %d): R=%d, G=%d, B=%d", screen_width - 1, screen_height - 1, r, g, b))

-- To visualize, you'd iterate through all pixels:
--[[
-- Pseudocode for a GDI drawing loop:
local start_time = os.clock()
while true do -- Or a loop that runs for a fixed duration
    local current_time = os.clock() - start_time

    -- Begin GDI drawing operations (e.g., clear screen)

    for y = 0, screen_height - 1 do
        for x = 0, screen_width - 1 do
            local r, g, b = get_color(x, y, current_time)
            -- Call your GDI function here, e.g.:
            -- gdi.SetPixel(x, y, gdi.RGB(r, g, b))
        end
    end

    -- End GDI drawing operations (e.g., refresh screen)

    -- Add a small delay to control frame rate if necessary
    -- os.sleep(0.01) -- If your environment supports it
end
]]
