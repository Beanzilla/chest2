
-- A collection of utility functions for making lua less difficult
chest2.tools = {}
local tools = chest2.tools

-- Centralize logging
tools.log = function (input)
    minetest.log("action", "[chest2] "..tostring(input))
end

-- Centralize errors
tools.error = function (input)
    error("[chest2] "..tostring(input))
end

-- Returns a table of the string split by the given seperation string
tools.split = function (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Converts the given string so the first letter is uppercase (Returns the converted string)
tools.firstToUpper = function (str)
    return (str:gsub("^%l", string.upper))
end

-- Returns space seperated position (Also strips extra precission)
tools.pos2str = function (pos)
    -- Because minetest's pos_to_string is a bit harder to parse
    return "" .. tostring(math.floor(pos.x)) .. " " .. tostring(math.floor(pos.y)) .. " " .. tostring(math.floor(pos.z))
end

-- Returns a xyz vector from space seperated position
tools.str2pos = function (str)
    local pos = tools.split(str, " ")
    return vector.new(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
end

-- https://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
-- Checks if a value is in the given table (True if the value exists, False otherwise)
tools.tableContainsValue = function (table, element)
    for key, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

tools.tableContainsKey = function (table, element)
    for key, value in pairs(table) do
        if key == element then
            return true
        end
    end
    return false
end

-- Given a table returns it's keys (Returns a table)
tools.tableKeys = function (t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(v)
    end
    return keys
end

-- Returns whole percentage given current and max values
tools.getPercent = function (current, max)
    if max == nil then
        max = 100
    end
    return math.floor( (current / max) * 100 )
end
