-- SEVEN CHAOS MODE 😈
math.randomseed(os.clock())

-- collect all screens (computer + monitors)
local screens = {}

-- computer terminal
table.insert(screens, {
    type = "computer",
    obj = term
})

-- monitors
for _, m in pairs({peripheral.find("monitor")}) do
    m.setTextScale(1)
    table.insert(screens, {
        type = "monitor",
        obj = m
    })
end

local colorsList = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red
}

while true do
    for _, screen in pairs(screens) do
        local t = screen.obj

        -- random text scale for monitors
        if screen.type == "monitor" then
            t.setTextScale(math.random(1, 5))
        end

        local w, h = t.getSize()
        t.setBackgroundColor(colors.black)
        t.clear()

        local fg = colorsList[math.random(#colorsList)]
        t.setTextColor(fg)

        for y = 1, h do
            t.setCursorPos(1, y)
            t.write(string.rep("7", w))
        end
    end

    sleep(0.15)
end
