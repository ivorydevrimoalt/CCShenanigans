local imageUrl = "https://wimg.rule34.xxx//samples/3120/sample_5bf5c373c2219bd18d246813cec47828.jpg?13989521"

print("Attempting to fetch content from: " .. imageUrl)
print("Please note: ComputerCraft cannot display images. This will likely print binary data.")

local response, err = http.get(imageUrl)

if response then
    -- Read all the content from the response.
    local content = response.readAll()
    response.close() -- Always close the response object to free up resources.

    print("\n--- Fetched Content (Binary Data) ---")
    -- Print the content. Since it's binary image data, it will look like gibberish.
    print(content)
    print("-------------------------------------")
    print("Fetch complete. Content printed above.")
else
    print("\nError fetching URL:")
    print(err) -- Print any error message received.
end

-- --- Displaying "ras4" on the console ---
-- Get the size of the current terminal (console).
local termWidth, termHeight = term.getSize()

-- The text we want to display.
local textToDisplay = "Yum"
local textLength = string.len(textToDisplay)

-- Calculate the X position to center the text.
-- Integer division is used to ensure it's a whole number.
local xPos = math.floor((termWidth - textLength) / 2) + 1 -- +1 because ComputerCraft is 1-indexed

-- Calculate the Y position to center the text vertically.
local yPos = math.floor(termHeight / 2) + 1 -- +1 because ComputerCraft is 1-indexed

-- Clear the entire console screen.
term.clear()

-- Set the text color. You can use any color from the 'colors' table, e.g., colors.red, colors.blue, etc.
-- For a list of available colors, you can type 'colors' in a ComputerCraft console.
term.setTextColour(colors.green) -- Set text to green

-- Set the cursor position to where we want to print the centered text.
term.setCursorPos(xPos, yPos)

-- Write the text to the console.
term.write(textToDisplay)

-- Reset text color to default (white) for subsequent prints, if any.
term.setTextColour(colors.white)

-- Wait for a few seconds so the user can see the centered text before the script exits.
sleep(5) -- Waits for 5 seconds.

print("\nELLIOT'S ASS")
