-- Find WIRELESS modem only
local modem = peripheral.find("modem", function(_, m)
    return m.isWireless()
end)

if not modem then
    error("Wireless modem required!")
end

modem.closeAll()
for ch = 0, 7 do
    modem.open(ch)
end

-- Collect monitors + terminal
local screens = {}
for _, name in pairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        table.insert(screens, peripheral.wrap(name))
    end
end
table.insert(screens, term)

local function draw(screen)
    if screen ~= term then
        screen.setTextScale(1)
    end
    local w, h = screen.getSize()
    screen.setBackgroundColor(colors.black)
    screen.clear()
    screen.setTextColor(colors.red)
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

flashAll() -- immediate test

parallel.waitForAny(
    function()
        while true do
            modem.transmit(1, 1, "7")
            os.sleep(0.2)
        end
    end,
    function()
        while true do
            os.pullEvent("modem_message")
            flashAll()
        end
    end
)
