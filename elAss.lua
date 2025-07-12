local targetUrl = "https://wimg.rule34.xxx//samples/3120/sample_5bf5c373c2219bd18d246813cec47828.jpg?13989521"

-- --- START OF SCRIPT EXECUTION ---

print("--- ComputerCraft URL Fetcher ---")
print("Target URL: " .. targetUrl)
print("")
print("WARNING: The content at this URL may be mature or explicit.")
print("         This script will fetch raw data, not display the image.")
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

-- Check if the request was successful.
if response then
    -- Read all content from the response.
    -- For binary files like images, this will be a long string of bytes.
    local content = response.readAll()
    response.close() -- Always close the response object to release resources.

    -- Get Content-Type and Content-Length from response headers.
    -- These headers provide metadata about the fetched content.
    local contentType = response.headers["Content-Type"] or "unknown/binary"
    local contentLength = #content -- Get the length of the fetched content in bytes.

    print("Fetch successful!")
    print("Content-Type: " .. contentType)
    print("Content-Length: " .. contentLength .. " bytes")

    -- Check if the content type indicates an image.
    if contentType:find("image", 1, true) then
        print("")
        print("This content appears to be an image file.")
        print("As explained, ComputerCraft cannot directly render complex image formats.")
        print("The data is raw binary and will not be visually meaningful.")
        print("")
        print("Displaying first 100 bytes (raw binary data):")
        -- Print a small substring of the content to show its raw, unreadable nature.
        -- This demonstrates that data was fetched, but it's not human-readable as an image.
        print(content:sub(1, math.min(100, contentLength)))
        if contentLength > 100 then
            print("... (truncated, " .. (contentLength - 100) .. " more bytes)")
        end
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
