--[[
  ComputerCraft 3D Auto-Completing Maze Script

  This script builds a 3D maze in the ComputerCraft world based on a
  predefined 2D layout. It then uses a Breadth-First Search (BFS)
  algorithm to find a path from a start point to an end point and
  highlights the solution by placing specific blocks.

  Limitations:
  - Does NOT fetch images from URLs. The maze layout must be defined
    directly in the script as a 2D table of 0s (path) and 1s (wall).
  - "3D" refers to building walls with height in the world, not complex
    graphical rendering.

  How to use:
  1. Place a turtle in an open area in your Minecraft world.
  2. Copy and paste this code into a new ComputerCraft program (e.g., `maze.lua`).
  3. Edit the `maze_layout`, `start_coords`, `end_coords`, `wall_block`,
     and `path_block` variables as desired.
  4. Run the script: `lua maze.lua`

  The turtle will then build the maze and show the solution.
]]

-- Configuration ---------------------------------------------------------------

-- Define your maze layout here.
-- 0 = path (empty space or floor block)
-- 1 = wall
-- The maze is defined from top-left (0,0) to bottom-right.
-- Ensure the maze is enclosed by walls for better pathfinding behavior.
local maze_layout = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1},
    {1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
}

-- Start and end coordinates (x, y) relative to the maze_layout.
-- (0,0) is the top-left corner of the maze_layout table.
local start_coords = {x = 1, y = 1} -- Example: (1,1) is the second row, second column (0-indexed)
local end_coords = {x = 11, y = 11} -- Example: (11,11) is the last row, last column

-- Block types to use for building the maze
local wall_block = "minecraft:stone"
local path_block = "minecraft:air" -- Use "minecraft:air" to clear paths
local solution_block = "minecraft:glowstone" -- Block to mark the solution path
local floor_block = "minecraft:cobblestone" -- Block for the floor of paths

-- Height of the maze walls
local maze_height = 3

-- Functions -------------------------------------------------------------------

-- Function to get the dimensions of the maze layout
local function getMazeDimensions(maze)
    local height = #maze
    local width = 0
    if height > 0 then
        width = #maze[1]
    end
    return width, height
end

-- Function to move the turtle to a specific world coordinate relative to its start
-- This function assumes the turtle starts at (0,0) relative to its initial position.
-- It moves the turtle to (target_x, target_y) on the current Y level.
local function moveToRelativeXY(target_x, target_y)
    local current_x, current_y = 0, 0
    local current_dir = 0 -- 0: North, 1: East, 2: South, 3: West (ComputerCraft standard)

    -- Function to adjust turtle direction
    local function turnTo(target_dir)
        if current_dir ~= target_dir then
            local diff = (target_dir - current_dir + 4) % 4
            if diff == 1 then
                turtle.turnRight()
            elseif diff == 2 then
                turtle.turnRight()
                turtle.turnRight()
            elseif diff == 3 then
                turtle.turnLeft()
            end
            current_dir = target_dir
        end
    end

    -- Move X
    if target_x > current_x then
        turnTo(1) -- East
        for i = 1, target_x - current_x do turtle.forward() end
    elseif target_x < current_x then
        turnTo(3) -- West
        for i = 1, current_x - target_x do turtle.forward() end
    end
    current_x = target_x

    -- Move Y (Z in Minecraft)
    if target_y > current_y then
        turnTo(2) -- South
        for i = 1, target_y - current_y do turtle.forward() end
    elseif target_y < current_y then
        turnTo(0) -- North
        for i = 1, current_y - target_y do turtle.forward() end
    end
    current_y = target_y
end

-- Function to place a block at the current turtle position
local function placeBlock(block_name)
    -- Select the correct slot for the block
    local selected_slot = -1
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == block_name then
            turtle.select(i)
            selected_slot = i
            break
        end
    end

    if selected_slot == -1 then
        print("Error: Block " .. block_name .. " not found in turtle inventory.")
        return false
    end

    -- Attempt to place the block
    local success, message = turtle.placeDown()
    if not success then
        -- Try to dig if something is already there
        turtle.digDown()
        sleep(0.1) -- Give time for block to break
        success, message = turtle.placeDown()
    end
    return success
end

-- Function to build the maze in the world
local function buildMaze(maze, wall_type, path_type, floor_type, height)
    local maze_width, maze_height_layout = getMazeDimensions(maze)
    print("Building maze (" .. maze_width .. "x" .. maze_height_layout .. ") with height " .. height .. "...")

    -- Store initial turtle position to return later
    local initial_x, initial_y, initial_z = turtle.getPos()
    local initial_dir = turtle.getDirection()

    -- Ensure turtle is on the ground level
    while not turtle.down() do
        -- If it can't go down, it's on the lowest possible level or blocked
        break
    end
    print("Turtle moved to ground level.")

    -- Build floor first
    print("Building maze floor...")
    for y = 0, maze_height_layout - 1 do
        moveToRelativeXY(0, y)
        for x = 0, maze_width - 1 do
            if maze[y + 1][x + 1] == 0 then -- Path
                placeBlock(floor_type)
            else -- Wall
                placeBlock(wall_type) -- Floor under wall
            end
            turtle.forward()
        end
    end

    -- Build walls
    print("Building maze walls...")
    for h = 1, height do
        moveToRelativeXY(0, 0) -- Return to maze origin for each layer
        turtle.up() -- Move up one level for the next layer of walls
        sleep(0.1) -- Give time for turtle to move

        for y = 0, maze_height_layout - 1 do
            moveToRelativeXY(0, y) -- Move to start of current row
            for x = 0, maze_width - 1 do
                if maze[y + 1][x + 1] == 1 then -- Wall
                    placeBlock(wall_type)
                else -- Path
                    placeBlock(path_type) -- Clear space or place air
                end
                turtle.forward()
            end
        end
    end

    print("Maze building complete.")

    -- Return turtle to initial position (relative to maze origin)
    moveToRelativeXY(0, 0)
    for i = 1, height do
        turtle.down()
    end
    print("Turtle returned to maze origin.")
end

-- Pathfinding (Breadth-First Search - BFS) -----------------------------------

-- Node structure for BFS
local PathNode = {}
PathNode.__index = PathNode

function PathNode.new(x, y, parent)
    local self = setmetatable({}, PathNode)
    self.x = x
    self.y = y
    self.parent = parent -- Reference to the previous node in the path
    return self
end

-- Function to find a path using BFS
local function findPath(maze, start_x, start_y, end_x, end_y)
    local maze_width, maze_height = getMazeDimensions(maze)
    print("Finding path from (" .. start_x .. "," .. start_y .. ") to (" .. end_x .. "," .. end_y .. ")...")

    -- Check if start/end are valid and on a path
    if start_x < 0 or start_x >= maze_width or start_y < 0 or start_y >= maze_height or
       end_x < 0 or end_x >= maze_width or end_y < 0 or end_y >= maze_height then
        print("Error: Start or end coordinates are out of maze bounds.")
        return nil
    end
    if maze[start_y + 1][start_x + 1] == 1 then
        print("Error: Start position is on a wall.")
        return nil
    end
    if maze[end_y + 1][end_x + 1] == 1 then
        print("Error: End position is on a wall.")
        return nil
    end

    local queue = {} -- Queue for BFS
    local visited = {} -- Keep track of visited cells to avoid loops

    -- Initialize visited table
    for y = 0, maze_height - 1 do
        visited[y] = {}
        for x = 0, maze_width - 1 do
            visited[y][x] = false
        end
    end

    -- Add start node to queue
    local start_node = PathNode.new(start_x, start_y, nil)
    table.insert(queue, start_node)
    visited[start_y][start_x] = true

    local found_node = nil

    while #queue > 0 do
        local current_node = table.remove(queue, 1)

        -- Check if we reached the end
        if current_node.x == end_x and current_node.y == end_y then
            found_node = current_node
            break
        end

        -- Define possible movements (up, down, left, right)
        local dx = {0, 0, 1, -1}
        local dy = {1, -1, 0, 0}

        for i = 1, 4 do
            local next_x = current_node.x + dx[i]
            local next_y = current_node.y + dy[i]

            -- Check bounds and if it's a valid path (0) and not visited
            if next_x >= 0 and next_x < maze_width and
               next_y >= 0 and next_y < maze_height and
               maze[next_y + 1][next_x + 1] == 0 and
               not visited[next_y][next_x] then

                visited[next_y][next_x] = true
                local next_node = PathNode.new(next_x, next_y, current_node)
                table.insert(queue, next_node)
            end
        end
    end

    if found_node then
        print("Path found!")
        -- Reconstruct path from end node back to start
        local path = {}
        local current = found_node
        while current do
            table.insert(path, 1, {x = current.x, y = current.y}) -- Insert at beginning to reverse order
            current = current.parent
        end
        return path
    else
        print("No path found.")
        return nil
    end
end

-- Function to solve the maze and highlight the path
local function solveAndHighlightPath(maze, path, solution_type)
    if not path then
        print("Cannot highlight path: No path provided.")
        return
    end

    print("Highlighting solution path...")

    -- Store initial turtle position to return later
    local initial_x, initial_y, initial_z = turtle.getPos()
    local initial_dir = turtle.getDirection()

    -- Ensure turtle is on the ground level
    while not turtle.down() do
        break
    end

    -- Move turtle to the start of the path and highlight
    for i, coords in ipairs(path) do
        moveToRelativeXY(coords.x, coords.y)
        placeBlock(solution_type)
        sleep(0.2) -- Small delay to visualize progress
    end

    print("Solution highlighted.")

    -- Return turtle to maze origin
    moveToRelativeXY(0, 0)
    -- No need to go up, as we were on the floor level for path highlight
end

-- Main Execution --------------------------------------------------------------

-- Ensure turtle is available
if not turtle then
    print("Error: This script requires a turtle.")
    return
end

print("Starting maze generation and solving.")

-- Build the maze
buildMaze(maze_layout, wall_block, path_block, floor_block, maze_height)

-- Find the path
local path = findPath(maze_layout, start_coords.x, start_coords.y, end_coords.x, end_coords.y)

-- Highlight the path if found
if path then
    solveAndHighlightPath(maze_layout, path, solution_block)
else
    print("Could not find a path to highlight.")
end

print("Script finished.")
