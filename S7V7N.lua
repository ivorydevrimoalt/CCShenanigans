math.randomseed(os.clock())

-- wrap wireless modem on TOP
local modem = peripheral.wrap("top")
if not modem or not modem.isWireless() then
    error("Wireless modem must be on TOP")
end

local CHANNEL = 7
modem.open(CHANNEL)

-- collect screens
local screens = {}
table.insert(screens, { type = "computer", obj = term })

for _, mon in pairs({ peripheral.find("monitor") }) do
    table.insert(screens, { type = "monitor", obj = mon })
end

local rainbow = {
    colors.red, colors.orange, colors.yellow,
    colors.lime, colors.green, colors.cyan,
    colors.lightBlue, colors.blue, colors.purple,
    colors.magenta, colors.pink
}

local function render(color, scale)
    for _, screen in pairs(screens) do
        local t = screen.obj

        if screen.type == "monitor" then
            t.setTextScale(scale)
        end

        local w, h = t.getSize()
        t.setBackgroundColor(colors.black)
        t.setTextColor(color)
        t.clear()

        for y = 1, h do
            t.setCursorPos(1, y)
            t.write(string.rep("777", math.ceil(w / 3)))
        end
    end
end

local function sendVirus()
    modem.transmit(CHANNEL, CHANNEL, {
        virus = true,
        color = rainbow[math.random(#rainbow)],
        scale = math.random(1, 5)
    })
end

-- main loop
while true do
    -- local chaos
    render(
        rainbow[math.random(#rainbow)],
        math.random(1, 5)
    )

    sendVirus()

    local timer = os.startTimer(0.15)

    while true do
        local event, a, b, c, d = os.pullEvent()

        if event == "modem_message" then
            local side, ch, rch, data = a, b, c, d
            if ch == CHANNEL and type(data) == "table" and data.virus then
                render(data.color, data.scale)
            end
        elseif event == "timer" and a == timer then
            break
        end
    end
end
