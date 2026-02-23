-- Find monitor
local monitor
for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "monitor" then
        monitor = peripheral.wrap(side)
        break
    end
end
if not monitor then error("No monitor found") end

-- 🔥 IMPORTANT: BIGGER PIXELS
monitor.setTextScale(1)  -- << THIS FIXES THE DARK TINY LOOK
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()

local w, h = monitor.getSize()
local cx = math.floor(w / 2)
local cy = math.floor(h / 2)

-- Cube size (big)
local size = 10

-- Cube vertices
local verts = {
    {-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},
    {-1,-1, 1},{1,-1, 1},{1,1, 1},{-1,1, 1}
}

local edges = {
    {1,2},{2,3},{3,4},{4,1},
    {5,6},{6,7},{7,8},{8,5},
    {1,5},{2,6},{3,7},{4,8}
}

local function rotX(v,a)
    return {v[1], v[2]*math.cos(a)-v[3]*math.sin(a), v[2]*math.sin(a)+v[3]*math.cos(a)}
end
local function rotY(v,a)
    return {v[1]*math.cos(a)+v[3]*math.sin(a), v[2], -v[1]*math.sin(a)+v[3]*math.cos(a)}
end

local function project(v)
    local z = v[3] + 6
    return {
        math.floor(cx + (v[1]*size)/z),
        math.floor(cy + (v[2]*size)/z)
    }
end

local a = 0

while true do
    monitor.clear()

    local p = {}
    for i,v in ipairs(verts) do
        local r = rotY(rotX(v,a), a*0.7)
        p[i] = project(r)
    end

    for _,e in ipairs(edges) do
        local A,B = p[e[1]], p[e[2]]
        local dx,dy = B[1]-A[1], B[2]-A[2]
        local steps = math.max(math.abs(dx), math.abs(dy))

        for i=0,steps do
            local x = math.floor(A[1] + dx*i/steps)
            local y = math.floor(A[2] + dy*i/steps)

            -- EXACT 7x6 CENTER AREA
            if math.abs(x-cx) <= 3 and math.abs(y-cy) <= 2 then
                monitor.setCursorPos(x,y)
                monitor.write("7")
            end
        end
    end

    a = a + 0.08
    sleep(0.05)
end
