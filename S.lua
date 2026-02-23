-- Random Beautiful Maths using ASCII "7"
-- Compatible with ComputerCraft

math.randomseed(os.clock())

-- Detect monitor on any side
local sides = {"top","bottom","left","right","front","back"}
local screen = term
local isMonitor = false

for _, side in ipairs(sides) do
    if peripheral.getType(side) == "monitor" then
        screen = peripheral.wrap(side)
        screen.setTextScale(0.5)
        isMonitor = true
        break
    end
end

screen.setBackgroundColor(colors.black)
screen.clear()

local w, h = screen.getSize()

local vars = {"x", "y"}
local ops = {"*", "^"}

-- Generate random math expression
local function randomMath()
    local parts = {}
    local length = math.random(2, 5)

    for i = 1, length do
        if math.random() < 0.5 then
            table.insert(parts, vars[math.random(#vars)])
        else
            table.insert(parts, tostring(math.random(2, 9)))
        end

        if i < length then
            table.insert(parts, ops[math.random(#ops)])
        end
    end

    return table.concat(parts)
end

-- Draw ASCII "7" math art
local function drawMath(expr)
    screen.clear()

    local color = math.random() < 0.5 and colors.red or colors.blue
    screen.setTextColor(color)

    local startX = math.random(1, math.max(1, w - #expr * 2))
    local startY = math.random(1, math.max(1, h - 3))

    for y = 0, 2 do
        screen.setCursorPos(startX, startY + y)
        for i = 1, #expr do
            screen.write("7 ")
        end
    end

    -- Overlay the math expression
    screen.setCursorPos(startX + 1, startY + 1)
    screen.write(expr)
end

-- Main loop
while true do
    local expr = randomMath()
    drawMath(expr)
    sleep(0.2)
end
