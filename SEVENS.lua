math.randomseed(os.clock())

-- collect all screens
local screens = {}

-- add computer terminal
table.insert(screens, {
    type = "computer",
    obj = term
})

-- add all monitors
for _, mon in pairs({ peripheral.find("monitor") }) do
    table.insert(screens, {
        type = "monitor",
        obj = mon
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

        -- random monitor scaling
        if screen.type == "monitor" then
            t.setTextScale(math.random(1, 2))
        end

        local w, h = t.getSize()

        t.setBackgroundColor(colors.black)
        t.clear()
        t.setTextColor(colorsList[math.random(#colorsList)])

        for y = 1, h do
            t.setCursorPos(1, y)
            t.write(string.rep("7", w))
        end
    end

    sleep(0.1)
end
