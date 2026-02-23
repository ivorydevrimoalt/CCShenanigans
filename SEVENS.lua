-- GLOBAL SEVEN STORM 🌈🔥
-- Reacts to ANY wireless signal on ANY channel
-- Spams random channels
-- Flashes 7s on ALL screens (monitors + terminal)

-- Find modem
local modem = peripheral.find("modem")
if not modem then
    error("Wireless modem required!")
end

-- Open a wide range of channels (safe max)
modem.closeAll()
for ch = 0, 65535 do
    modem.open(ch)
end

-- Collect monitors
local screens = {}
for _, name in pairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        table.insert(screens, peripheral.wrap(name))
    end
end

-- Include terminal
table.insert(screens, term)

math.randomseed(os.clock() * 100000)

local colorsList = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red
}

local function randColor()
    return colorsList[math.random(#colorsList)]
end

local function draw(screen)
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
        draw(s)
    end
end

-- Broadcast random noise everywhere
local function broadcaster()
    while true do
        modem.transmit(math.random(0, 65535), math.random(0, 65535), "7")
        os.sleep(0.2)
    end
end

-- Listen to EVERYTHING
local function listener()
    while true do
        os.pullEvent("modem_message")
        flashAll()
    end
end

parallel.waitForAny(broadcaster, listener)
