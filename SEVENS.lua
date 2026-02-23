local modem = peripheral.find("modem", function(_, m)
    return m.isWireless()
end)
assert(modem, "Wireless modem required")

local monitor = peripheral.find("monitor")
assert(monitor, "Monitor required")

modem.open(777)

local id = os.getComputerID()

while true do
    local _, _, ch, _, msg = os.pullEvent("modem_message")
    if ch == 777 and msg == "PING" then
        modem.transmit(777, 777, { id = id })
    elseif ch == 777 and msg == "FLASH" then
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setTextColor(colors.red)
        local w, h = monitor.getSize()
        for y = 1, h do
            monitor.setCursorPos(1, y)
            monitor.write(string.rep("7", w))
        end
    end
end
