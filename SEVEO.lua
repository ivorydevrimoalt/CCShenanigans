-- Collect all screens (computer + all monitors)
local screens = {}

-- Add the computer terminal
table.insert(screens, term)

-- Find all monitors
for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "monitor" then
        table.insert(screens, peripheral.wrap(side))
    end
end

-- Color list (skip black so it's visible)
local colors = {
    colors.white, colors.red, colors.orange, colors.yellow,
    colors.lime, colors.green, colors.cyan, colors.blue,
    colors.purple, colors.magenta, colors.pink, colors.lightBlue
}

-- Big "7" patterns (scales up dynamically)
local function drawSeven(t, x, y, size)
    for i = 0, size - 1 do
        t.setCursorPos(x + i, y)
        t.write("█")
    end
    for i = 1, size do
        t.setCursorPos(x + size - i, y + i)
        t.write("█")
    end
end

-- Main loop
while true do
    for _, t in ipairs(screens) do
        local w, h = t.getSize()

        -- Random style
        local color = colors[math.random(#colors)]
        local size = math.random(2, math.floor(math.min(w, h) / 2))
        local x = math.random(1, math.max(1, w - size))
        local y = math.random(1, math.max(1, h - size))

        -- Clear + set color
        t.setBackgroundColor(colors.black)
        t.clear()
        t.setTextColor(color)

        -- Draw the 7
        drawSeven(t, x, y, size)
    end

    sleep(0.15) -- Flash speed (lower = faster)
end
