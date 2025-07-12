-- This script draws a 50x19 text image on the ComputerCraft terminal.
-- It will simply print the characters as defined in the image_rows.

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

-- Clear the terminal and set text scale to 1 for pixel-perfect drawing (still relevant for character size)
term.clear()
term.setTextScale(1)

---
--- Image Data
---

-- Dummy image data (50x19 ratio)
-- Characters will be printed as they are.
-- Non-ASCII characters have been replaced with ASCII equivalents to prevent encoding issues.
local image_rows = {
    "                                                  ",
    "      __    __                                    ",
    "     /  \  /  \                                   ",
    "   //         //    Sorry i repeat again~         ",
    "        /----\       my booty is not on           ",
    "         L__rJ                 the menu~          ",
    "                                 hehe~~           ",
    "                                                  ",
    "--------------------------------------------------",
    "        ____                                      ",
    "      |Roblox|                                    ",
    "      /______\\                                   ",
    "     |  ^ ^   |      Elliot's ass                  ",
    "      \\__u___/        ascii all by                ",
    "        |  |               ivorydevrimo           ",
    "      _O_|__ \\ O_____      ivorydevrimoqr         ",
    "    /       \\ /      \\     ivorydevrimo3         ",
    "    |        |         |                          ",
    "     \\______/ \\_______/                           "
}

---
--- Drawing Logic
---

-- Loop through each row and print it directly
for y = 1, #image_rows do
    local current_row_data = image_rows[y]
    term.setCursorPos(1, y) -- Set cursor to the beginning of the current line
    term.write(current_row_data) -- Print the entire row as text
    print(current_row_data)
end

---
--- Cleanup and User Interaction
---

-- Reset cursor after drawing
term.setCursorPos(1, 1)
-- No background color reset needed as we're not setting them.
