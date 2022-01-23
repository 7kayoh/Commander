-- pcall.lua
-- 7kayoh
-- Jan 23, 2022

local MAX_TRY_LIMIT = 4

return function(func: (any) -> (any), ...)
    local result = {pcall(func, ...)}
    local count = 1
    
    while not result[1] and count <= MAX_TRY_LIMIT do
        result = {pcall(func, ...)}
        count += 1
    end

    if not result[1] then
        warn("pcall failed: " .. tostring(result[2]))
    end

    return table.remove(result, 1), unpack(result)
end