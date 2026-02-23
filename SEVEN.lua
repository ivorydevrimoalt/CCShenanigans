-- GLOBAL SEVEN STORM 🌈
-- Flashes 7s on all screens, synced wirelessly
-- Works on any monitor size, no channel overflow

local CHANNEL = 777 -- shared chaos channel

-- Find wireless modem
local modem = peripheral.find("modem")
if not modem then
    error("Wireless modem required!")
end
modem.open(CHANNEL)

-- Collect all monitors
local screens = {}
for _, name in pairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        table.insert(screens, peripheral.wrap(name))
    end
end

-- Include computer terminal
table.insert(screens, term)

math.randomseed(os.clock() * 100000)

local colorList = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red
}

local function randColor()
    return colorList[math.random(#colorList)]
end

local function drawSevens(screen)
    if screen ~= term then
        screen.setTextScale(math.random(5, 20) / 10)
    end

    local w, h = screen.getSize()
    screen.setBackgroundColor(colors.black)
    screen.clear()
    screen.setTextColor(randColor())

    for y = 1, h do
        screen.setCursorPos(1, y)
        screen.write(string.rep("7", w))
    end
end

local function flashAll()
    for _, s in ipairs(screens) do
        drawSevens(s)
    end
end

-- Broadcast loop (syncs all computers)
local function broadcaster()
    while true do
        modem.transmit(CHANNEL, CHANNEL, "7")
        os.sleep(0.25)
    end
end

-- Listener loop
local function listener()
    while true do
        local _, _, _, _, msg = os.pullEvent("modem_message")
        if msg then
            flashAll()
        end
    end
end

parallel.waitForAny(broadcaster, listener)
