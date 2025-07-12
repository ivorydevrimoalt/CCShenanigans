-- This script draws a 50x19 pixel image on the ComputerCraft terminal.
-- Pixels represented by ' ' will be black.
-- Pixels represented by 'F' will be a fixed color (blue in this example).
-- All other pixels ('X' in this example) will have a random background color.

---
--- Monitor Setup
---

-- Attempt to wrap a connected monitor first. If no monitor is found,
-- it will default to the current computer's terminal.
-- You can change "right" to the side your monitor is actually on if you have one.
local term = peripheral.wrap("right")
if not term then term = peripheral.wrap("left") end
if not term then term = peripheral.wrap("top") end
if not term then term = peripheral.wrap("bottom") end
if not term then term = peripheral.wrap("front") end
if not term then term = peripheral.wrap("back") end
if not term then term = term.current() end -- Fallback to current terminal

-- Access the global colors table provided by ComputerCraft
local colors = colors

-- Clear the terminal and set text scale to 1 for pixel-perfect drawing
term.clear()
term.setTextScale(1)

---
--- Color Definitions
---

-- Define the fixed color that will not be randomized
local FIXED_COLOR = colors.blue
local FIXED_CHAR = 'F' -- Character representing the fixed color in the image data

-- Define a pool of colors for randomization (excluding black and the fixed color)
local RANDOM_COLOR_POOL = {
    colors.white,
    colors.orange,
    colors.magenta,
    colors.lightBlue,
    colors.yellow,
    colors.lime,
    colors.pink,
    colors.gray,
    colors.lightGray,
    colors.cyan,
    colors.purple,
    colors.brown,
    colors.green,
    colors.red
}

-- Remove the fixed color from the random pool to ensure it's truly fixed
for i = #RANDOM_COLOR_POOL, 1, -1 do
    if RANDOM_COLOR_POOL[i] == FIXED_COLOR then
        table.remove(RANDOM_COLOR_POOL, i)
    end
end

-- Function to get a random color from the defined pool
local function getRandomColor()
    return RANDOM_COLOR_POOL[math.random(#RANDOM_COLOR_POOL)]
end

---
--- Image Data
---

-- Dummy image data (50x19 ratio)
-- 'X' will be a random color
-- ' ' will be black
-- 'F' will be the FIXED_COLOR (blue)
-- You can modify this data to create your own 50x19 image pattern.
-- All row data is now directly stored in the image_rows table.
-- Non-ASCII characters like '█' and special characters like '~' that might cause encoding issues
-- have been replaced with 'X' to ensure compatibility.
local image_rows = {
    "                                                  ",
    "      XX    XX                                    ",
    "     X  X  X  X                                   ",
    "   //         //    Sorry i repeat again~         ",
    "        XXXXXX       my booty is not on           ",
    "        X    X                 the menu~          ",
    "          XXXX                   hehe~~           ",
    "                                                  ",
    "--------------------------------------------------",
    "        ____                                      ",
    "      |Roblox|                                    ",
    "      /______\\                                   ",
    "      | ^ ^  |      Elliot's ass                  ",
    "      \\__u___/        ascii all by                ",
    "        |  |               ivorydevrimo           ",
    "      ___|__ \\ ______      ivorydevrimoqr         ",
    "    /  o    \\ /    o \\     ivorydevrimo3         ",
    "   |         |         |                          ",
    "    \\______/ \\_______/                           "
}

---
--- Drawing Logic
---

-- Loop through each row and column to draw the image
for y = 1, #image_rows do
    local current_row_data = image_rows[y]
    -- Use string.byte for character-by-character processing to avoid multi-byte issues
    for x = 1, #current_row_data do -- Use # for byte length with ASCII
        local char = string.sub(current_row_data, x, x)
        term.setCursorPos(x, y)

        if char == ' ' then
            term.setBackgroundColor(colors.black)
        elseif char == FIXED_CHAR then
            term.setBackgroundColor(FIXED_COLOR)
        else
            -- For any character that isn't ' ' or 'F', treat it as a random color pixel.
            -- This handles 'X' and any other ASCII characters you might put in your pattern.
            term.setBackgroundColor(getRandomColor())
        end
        term.write(" ") -- Draw a space character to show the background color
    end
end

---
--- Cleanup and User Interaction
---

-- Reset cursor and background after drawing
term.setCursorPos(1, 1)
term.setBackgroundColor(colors.black)
term.clearLine() -- Clear the first line to ensure cursor is visible

print("Image drawn! Press any key to clear.")
os.pullEvent("key") -- Wait for any key press
term.clear() -- Clear the screen after key press
term.setCursorPos(1,1)
term.setBackgroundColor(colors.black)
