-- ComputerCraft Lua Script: URL Fetcher for Binary Data with Simulated Color Display
--
-- This script fetches raw data from a given URL. If the data is an image,
-- it will attempt to display a *simulated* color representation on the
-- computer's built-in text console.
--
-- IMPORTANT LIMITATIONS:
-- 1. Actual Image Rendering: ComputerCraft's built-in displays (on computers/pocket PCs)
--    are primarily text-based. They cannot directly decode and display complex
--    image formats like JPG, PNG, or GIF with their full color palettes and resolution.
--    This script will fetch the raw binary data, but the "color display" is a
--    highly simplified, blocky representation based on the raw bytes, NOT the actual image.
-- 2. Content Warning: The URL provided by the user may contain mature or explicit
--    content. Please be mindful of this before running the script or sharing it.
--
-- Usage:
-- 1. Save this script on your ComputerCraft computer (e.g., as 'fetchimage').
-- 2. Run it by typing 'fetchimage' in the computer's console.
-- 3. Ensure HTTP requests are enabled in your ComputerCraft configuration.

-- Define the URL to fetch data from.
-- This URL points to a JPG image, which will be fetched as raw binary data.
local targetUrl = "https://wimg.rule34.xxx//samples/3120/sample_5bf5c373c2219bd18d246813cec47828.jpg?13989521"

-- --- START OF SCRIPT EXECUTION ---

print("--- ComputerCraft URL Fetcher ---")
print("Target URL: " .. targetUrl)
print("")
print("WARNING: The content at this URL may be mature or explicit.")
print("         This script will fetch raw data.")
print("         It will attempt a *simulated* color display, NOT the actual image.")
print("")
print("Attempting to fetch data...")

-- Check if the 'http' API is available.
-- The 'http' API is essential for making web requests in ComputerCraft.
if not http then
    print("ERROR: The 'http' API is not available.")
    print("       Please ensure HTTP requests are enabled in your ComputerCraft settings.")
    return -- Exit the script if http API is missing.
end

-- Attempt to perform an HTTP GET request to the target URL.
-- The 'http.get()' function returns two values:
-- 1. 'response': A file-like object if the request was successful, allowing you to read the content.
-- 2. 'err': An error message string if the request failed.
local response, err = http.get(targetUrl)

-- Check if the request was successful and has headers.
if response then
    -- Read all content from the response.
    -- For binary files like images, this will be a long string of bytes.
    local content = response.readAll()
    response.close() -- Always close the response object to release resources.

    -- Get Content-Type and Content-Length from response headers.
    -- Added a check for response.headers to prevent "attempt to index field 'headers' (a nil value)" error.
    local contentType = (response.headers and response.headers["Content-Type"]) or "unknown/binary"
    local contentLength = #content -- Get the length of the fetched content in bytes.

    print("Fetch successful!")
    print("Content-Type: " .. contentType)
    print("Content-Length: " .. contentLength .. " bytes")

    -- Check if the content type indicates an image.
    if contentType:find("image", 1, true) then
        print("")
        print("This content appears to be an image file.")
        print("As explained, ComputerCraft cannot directly render complex image formats.")
        print("The data is raw binary. Below is a *simulated* color representation.")
        print("It will NOT look like the actual JPG image, but rather a mosaic of colors.")
        print("")

        -- Define ComputerCraft's available colors (numerical values from the 'colors' API)
        -- These are the 16 standard colors available in ComputerCraft.
        local ccColors = {
            colors.black, colors.blue, colors.brown, colors.cyan,
            colors.gray, colors.green, colors.lightBlue, colors.lightGray,
            colors.lime, colors.magenta, colors.orange, colors.pink,
            colors.purple, colors.red, colors.white, colors.yellow
        }
        local numColors = #ccColors -- Number of available colors (16)

        local termWidth, termHeight = term.getSize() -- Get current terminal dimensions
        local currentX, currentY = term.getCursorPos() -- Get current cursor position

        -- Clear the screen for the color display
        term.clear()
        term.setCursorPos(1,1)

        -- Iterate through each byte of the content
        for i = 1, contentLength do
            local byteValue = string.byte(content, i) -- Get the numerical value of the current byte (0-255)
            -- Map the byte value to a color index using modulo.
            -- This distributes the 256 possible byte values across the 16 colors.
            local colorIndex = (byteValue % numColors) + 1 -- +1 because Lua arrays are 1-indexed (1 to 16)
            local currentColor = ccColors[colorIndex] -- Get the actual color constant

            -- Set the background color for the next character
            term.setBackgroundColor(currentColor)
            term.write(" ") -- Print a space character. The color will be visible as the background of this space.

            -- Move cursor to the next position
            currentX = currentX + 1
            if currentX > termWidth then
                -- If we reach the end of the line, move to the next line
                currentX = 1
                currentY = currentY + 1
                term.setCursorPos(currentX, currentY)

                -- Stop if we've filled the screen to prevent scrolling indefinitely
                if currentY > termHeight then
                    print("\n--- Display truncated: Screen full ---")
                    break
                end
            end
        end

        -- Reset background color to default black after drawing
        term.setBackgroundColor(colors.black)
        -- Move cursor to a new line after the simulated display
        term.setCursorPos(1, currentY + 1)
        print("")
        print("--- End of Simulated Color Representation ---")
        print("The above is a visual interpretation of the binary data, not the actual image.")
        print("For true image display, a 'monitor' block and image processing are required.")

    else
        -- If it's not an image (or content type is unknown), print the full content.
        -- This might be useful if the URL unexpectedly returned text.
        print("")
        print("Content is not recognized as an image. Displaying full content:")
        print(content)
    end
else
    -- Handle cases where the HTTP request failed.
    print("ERROR: Failed to fetch URL.")
    print("Reason: " .. (err or "Unknown error occurred."))
    print("Possible causes include: incorrect URL, no internet connection, or HTTP requests blocked.")
end

print("")
print("--- End of Script ---")
print("For visual image display in ComputerCraft, you would typically need:")
print("1. A connected 'monitor' block.")
print("2. Images pre-converted into a very simple, pixel-by-pixel format that")
print("   can be drawn using 'monitor_side.setPixel(x, y, color)' or similar.")
print("   Direct JPG/PNG decoding is beyond ComputerCraft's capabilities.")
