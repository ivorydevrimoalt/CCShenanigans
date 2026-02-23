-- Find a monitor on any side
local monitor
for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "monitor" then
        monitor = peripheral.wrap(side)
        break
    end
end

if not monitor then
    error("No monitor found!")
end

monitor.setTextScale(0.5)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()

local w, h = monitor.getSize()

-- Screen center
local cx = math.floor(w / 2)
local cy = math.floor(h / 2)

-- 🔥 BIGGER cube
local size = 7

-- Cube vertices
local vertices = {
    {-1, -1, -1}, {1, -1, -1},
    {1,  1, -1}, {-1,  1, -1},
    {-1, -1,  1}, {1, -1,  1},
    {1,  1,  1}, {-1,  1,  1},
}

-- Cube edges
local edges = {
    {1,2},{2,3},{3,4},{4,1},
    {5,6},{6,7},{7,8},{8,5},
    {1,5},{2,6},{3,7},{4,8}
}

-- Rotation helpers
local function rotateX(v, a)
    return {
        v[1],
        v[2] * math.cos(a) - v[3] * math.sin(a),
        v[2] * math.sin(a) + v[3] * math.cos(a)
    }
end

local function rotateY(v, a)
    return {
        v[1] * math.cos(a) + v[3] * math.sin(a),
        v[2],
        -v[1] * math.sin(a) + v[3] * math.cos(a)
    }
end

-- Projection
local function project(v)
    local z = v[3] + 6
    return {
        math.floor(cx + (v[1] * size) / z),
        math.floor(cy + (v[2] * size) / z)
    }
end

local angle = 0

while true do
    monitor.clear()

    local projected = {}

    for i, v in ipairs(vertices) do
        local r = rotateY(rotateX(v, angle), angle * 0.6)
        projected[i] = project(r)
    end

    for _, e in ipairs(edges) do
        local a = projected[e[1]]
        local b = projected[e[2]]

        local dx = b[1] - a[1]
        local dy = b[2] - a[2]
        local steps = math.max(math.abs(dx), math.abs(dy))

        for i = 0, steps do
            local x = math.floor(a[1] + dx * i / steps)
            local y = math.floor(a[2] + dy * i / steps)

            -- Keep inside center 7x6 area
            if math.abs(x - cx) <= 3 and math.abs(y - cy) <= 2 then
                monitor.setCursorPos(x, y)
                monitor.write("7")
            end
        end
    end

    angle = angle + 0.08
    sleep(0.05)
end
