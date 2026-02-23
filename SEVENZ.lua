math.randomseed(os.clock())

-- find wireless modem
local modem = peripheral.find("modem", function(_, m)
    return m.isWireless()
end)

if not modem then
    error("No wireless modem found")
end

rednet.open(peripheral.getName(modem))

local CHANNEL = 7

-- collect all screens
local screens = {}

table.insert(screens, { type = "computer", obj = term })

for _, mon in pairs({ peripheral.find("monitor") }) do
    table.insert(screens, { type = "monitor", obj = mon })
end

local colorsList = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red
}

-- elect broadcaster (lowest computer ID wins)
local myID = os.getComputerID()
rednet.broadcast(myID, CHANNEL)

local broadcaster = true
local timer = os.startTimer(0.5)

while true do
    local event, a, b, c = os.pullEvent()

    -- ID election
    if event == "rednet_message" and c == CHANNEL and type(b) == "number" then
        if b < myID then
            broadcaster = false
        end
    end

    -- broadcaster sends chaos packets
    if event == "timer" and broadcaster then
        local packet = {
            color = colorsList[math.random(#colorsList)],
            scale = math.random(1, 5)
        }
        rednet.broadcast(packet, CHANNEL)
        timer = os.startTimer(0.1)
    end

    -- everyone renders
    if event == "rednet_message" and c == CHANNEL and type(b) == "table" then
        for _, screen in pairs(screens) do
            local t = screen.obj

            if screen.type == "monitor" then
                t.setTextScale(b.scale)
            end

            local w, h = t.getSize()
            t.setBackgroundColor(colors.black)
            t.setTextColor(b.color)
            t.clear()

            for y = 1, h do
                t.setCursorPos(1, y)
                t.write(string.rep("7", w))
            end
        end
    end
end
