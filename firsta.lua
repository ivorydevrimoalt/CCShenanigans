-- Configuration
local DELAY = 0.05 -- Smaller values make it faster, larger values make it slower

term.clear()
term.setTextScale(1)

local width, height = term.getSize()

local function hslToCCColor(h, s, l)
    if h >= 0 and h < 60 then return colors.red
    elseif h >= 60 and h < 120 then return colors.yellow
    elseif h >= 120 and h < 180 then return colors.green
    elseif h >= 180 and h < 240 then return colors.cyan
    elseif h >= 240 and h < 300 then return colors.blue
    else return colors.magenta
    end
end

local hue = 0
while true do
    for y = 1, height do
        for x = 1, width do
            local currentHue = (hue + (x * 2) + (y * 5)) % 360
            local color = hslToCCColor(currentHue, 1, 0.5)

            term.setBackgroundColor(color)
            term.setCursorPos(x, y)
            term.write(" ")
        end
    end

    hue = (hue + 10) % 360

    sleep(DELAY)
end
