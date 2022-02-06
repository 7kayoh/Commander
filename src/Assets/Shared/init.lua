local Module = {}

return setmetatable(Module, {
	__call = function(_, alias: Instance)
		Module.Alias = alias
	end,

	__index = function(_, index: string)
		if Module.Alias then
			return Module.Alias[index]
		end
		error("Alias is not set yet")
	end,
})
