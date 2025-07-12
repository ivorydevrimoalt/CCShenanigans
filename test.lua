-- ComputerCraft Static Noise with "TSET" Centered
local w, h = term.getSize()
local sideChars = {'|', '/', '-', '\\'} -- Rotating sides
local sideIndex = 1

-- Function to get a random grayscale color
local function getGray()
  return math.random() > 0.5 and colors.white or colors.black
end

-- Function to get a random rainbow color
local rainbowColors = {
  colors.red, colors.orange, colors.yellow, colors.lime,
  colors.green, colors.cyan, colors.blue, colors.purple, colors.pink
}

local function getRainbow()
  return rainbowColors[math.random(#rainbowColors)]
end

-- Center coordinates for "TSET"
local centerX = math.floor(w / 2 - 2)
local centerY = math.floor(h / 2)

-- Main loop
while true do
  term.setCursorPos(1, 1)
  for y = 1, h do
    for x = 1, w do
      if x == 1 or x == w then
        -- Side borders with rotation
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.write(sideChars[sideIndex])
      elseif y == centerY and x >= centerX and x <= centerX + 3 then
        -- Center "TSET" text
        local char = string.sub("TSET", x - centerX + 1, x - centerX + 1)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.write(char)
      elseif x < w / 2 then
        -- Left half B&W static
        term.setTextColor(getGray())
        term.setBackgroundColor(getGray())
        term.write(" ")
      else
        -- Right half rainbow static
        term.setTextColor(getRainbow())
        term.setBackgroundColor(getRainbow())
        term.write(" ")
      end
    end
  end
  sideIndex = (sideIndex % #sideChars) + 1
  sleep(0.05)
end
