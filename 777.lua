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

-- render 777 chaos
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

-- send virus packet
local function sendVirus()
    modem.transmit(CHANNEL, CHANNEL, {
        virus = true,
        color = rainbow[math.random(#rainbow)],
        scale = math.random(1, 5)
    })
end

while true do
    -- flash locally
    local packet = {
        color = rainbow[math.random(#rainbow)],
        scale = math.random(1, 5)
    }
    render(packet.color, packet.scale)

    -- infect others
    sendVirus()

    -- listen for incoming virus
    local event, side, ch, rch, data = os.pullEventTimeout("modem_message", 0.15)
    if event and ch == CHANNEL and type(data) == "table" and data.virus then
        render(data.color, data.scale)
    end
end
