local modem = peripheral.find("modem", function(_, m)
    return m.isWireless()
end)
assert(modem, "Wireless modem required")

local monitor = peripheral.find("monitor")
assert(monitor, "Monitor required")

local CHANNEL = 7
modem.open(CHANNEL)

monitor.setBackgroundColor(colors.black)
monitor.setTextScale(1)

local function drawSevens()
    monitor.clear()
    local w, h = monitor.getSize()
    monitor.setTextColor(colors.red)
    for y = 1, h do
        monitor.setCursorPos(1, y)
        monitor.write(string.rep("7", w))
    end
end

print("Listening on channel", CHANNEL)

while true do
    local _, _, ch, _, msg = os.pullEvent("modem_message")
    if ch == CHANNEL and msg == "SEVEN" then
        drawSevens()
    end
end
