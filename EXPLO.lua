local w, h = term.getSize()
term.setBackgroundColor(colors.black)
term.clear()

local text = "COMPUTERCRAFT LUA DEMO"
local letters = {}
local centerX, centerY = math.floor(w/2), math.floor(h/2)

-- Fill letters table with positions and characters
for i = 1, #text do
    local x = math.random(1, w)
    local y = math.random(1, h)
    local char = text:sub(i,i)

    -- Replace 5 random letters with unicode
    if math.random(1, #text) <= 5 then
        char = utf8.char(math.random(0x2500, 0x25FF)) -- box drawing & symbols
    end

    table.insert(letters, {
        x = x,
        y = y,
        targetX = centerX,
        targetY = centerY,
        char = char,
        color = 2 ^ math.random(0, 15)
    })
end

-- Function to draw all letters
local function drawLetters()
    term.clear()
    for _, l in ipairs(letters) do
        term.setCursorPos(math.floor(l.x), math.floor(l.y))
        term.setTextColor(l.color)
        term.write(l.char)
    end
end

-- Move all letters to center
for t = 1, 20 do
    for _, l in ipairs(letters) do
        l.x = l.x + (l.targetX - l.x) * 0.2
        l.y = l.y + (l.targetY - l.y) * 0.2
    end
    drawLetters()
    sleep(0.05)
end

-- FLASH EFFECT
for i = 1, 6 do
    term.setBackgroundColor(i % 2 == 0 and colors.white or colors.black)
    term.clear()
    sleep(0.1)
end

-- UNICODE CHAOS MODE: bounce random letters
for i = 1, 100 do
    term.setBackgroundColor(colors.black)
    term.clear()
    for _ = 1, 20 do
        local x = math.random(1, w)
        local y = math.random(1, h)
        local char = utf8.char(math.random(0x2500, 0x25FF))
        local color = 2 ^ math.random(0, 15)
        term.setCursorPos(x, y)
        term.setTextColor(color)
        term.write(char)
    end
    sleep(0.05)
end

-- Cleanup
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)
print("!!exp!!exp!!exp!!exp!!exp!!exp!!")
print("           EXPLODED")
print("!!exp!!exp!!exp!!exp!!exp!!exp!!")
print("   Made only by Ivorydevrimo")
print("!!exp!!exp!!exp!!exp!!exp!!exp!!")
