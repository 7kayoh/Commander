-- pcall.lua
-- 7kayoh
-- Jan 23, 2022

local MAX_TRY_LIMIT = 4

return function(func: (any) -> (any), ...)
	local result = nil
	for _ = 1, MAX_TRY_LIMIT do
		result = { pcall(func, ...) }
		if result[1] then
			break
		end
	end

	if not result[1] then
		error("pcall | process exited with error: " .. tostring(result[2]))
	end

	return table.remove(result, 1), unpack(result)
end
