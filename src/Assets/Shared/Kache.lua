local DataStoreService = game:GetService("DataStoreService")

local Kache = {}
Kache.__VERSION = "1.0.0"

Kache.Enum = {}
Kache.Enum.Event = {
	Set = "Set",
	Unset = "Unset",
	Clear = "Clear"
}

local _sharedInstances = {}
local _crossServerInstances = {}

--[[
	A yielding version of xpcall.

	See https://devforum.roblox.com/t/xpcall-still-cannot-yield-across-metamethodc-call-boundary/5069/6.
]]
local function yxpcall(f, handler)
	local success, response = pcall(f)
	if success then
		return true, response
	else
		return false, handler(response)
	end
end

--[[
	Create a new Kache instance.

	@param defaultTTL The default TTL to use if a TTL is not provided.
	@param passiveExpiry Whether or not to enable passive expiry. Enabled by default if there is a default TTL set.

	@returns A Kache instance.
]]
function Kache.new(defaultTTL: number?, passiveExpiry: boolean?)
	local inst = setmetatable({
		_items = {},

		_defaultTTL = defaultTTL or -1,

		_passiveExpiry = passiveExpiry ~= nil and passiveExpiry or defaultTTL ~= nil,
		_expiryCoroutine = 0,

		_crossServer = false,
		_cacheUpdate = Instance.new("BindableEvent")
	}, Kache)

	if inst._passiveExpiry then
		inst._expiryCoroutine = coroutine.create(function()
			while true do
				while inst:Count() < 20 do task.wait() end -- don't run unless we have 20+ items

				while true do
					if inst:Count() < 20 then break end -- stop running if we hit less than 20, this just becomes a waste of time

					-- redis style passive expiry time :)

					local keys = {}

					for k, _ in pairs(inst._items) do
						table.insert(keys, k)
					end

					-- shuffle keys to take random first sampleSize
					for i = #keys, 2, -1 do
						local j = math.random(i)
						keys[i], keys[j] = keys[j], keys[i]
					end

					local keysToTest = {}
					for i = 1, 20, 1 do
						table.insert(keysToTest, keys[i])
					end

					local expired = 0
					for _, v in pairs(keysToTest) do
						if inst:Get(v, "$Kache$expired") == "$Kache$expired" then
							expired += 1
						end
					end

					if inst:Count() == 0 then
						break -- if we've expired all items
					end

					if (expired / 20) < 0.25 then
						break -- if less than 25% of the keys we picked actually expired
					end
				end

				task.wait(1)
			end
		end)
		coroutine.resume(inst._expiryCoroutine)
	end

	return inst
end

--[[
	Create a new Kache instance, or gets one if one already exists by name.

	@param name The name of the instance.
	@param defaultTTL The default TTL to use if a TTL is not provided.
	@param passiveExpiry Whether or not to enable passive expiry. Enabled by default if there is a default TTL set.

	@returns A Kache instance.
]]
function Kache.shared(name: string, defaultTTL: number?, passiveExpiry: boolean?)
	if _sharedInstances[name] then return _sharedInstances[name] end

	_sharedInstances[name] = Kache.new(defaultTTL, passiveExpiry)
	return _sharedInstances[name]
end

--[[
	Create a new cross-server cache.

	@param name The name of the instance.
	@param defaultTTL The default TTL to use if a TTL is not provided.

	@returns A Kache instance.
]]
function Kache.crossServer(name: string, defaultTTL: number?)
	if _crossServerInstances[name] then return _crossServerInstances[name] end

	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("KacheCrossServer", name)
	end)

	if not ok then error("Failed to get datastore: " .. result) end

	local inst = setmetatable({
		_items = {},

		_defaultTTL = defaultTTL or -1,

		_crossServer = true,
		_cacheUpdate = Instance.new("BindableEvent"),

		-- cross-server specific data
		_dataStore = result
	}, Kache)

	inst._cacheUpdate.Event:Connect(function(e, key, value, expiry)
		if e == Kache.Enum.Event.Set then
			yxpcall(function()
				inst._dataStore:SetAsync(key, { value = value, expiry = expiry })
			end, function(err)
				warn("[Kache] Failed to write to cross-server cache datastore:", err)
			end)
		elseif e == Kache.Enum.Event.Unset then
			yxpcall(function()
				inst._dataStore:RemoveAsync(key)
			end, function(err)
				warn("[Kache] Failed to write to cross-server cache datastore:", err)
			end)
		end
	end)

	_crossServerInstances[name] = inst

	return inst
end

--[[
	Metatable index to provide an alias to Get.
]]
function Kache:__index(index)
	if Kache[index] then
		return Kache[index]
	else
		return self:Get(index)
	end
end

--[[
	Metatable index to provide an alias to Set.
]]
function Kache:__newindex(index, value)
	if value == nil then
		return self:Unset(index)
	end

	return self:Set(index, value)
end

--[[
	Sets an item in cache.

	@param key The key the item should be under.
	@param value The value of the key.
	@param clearAfter How long the

	@returns If the object is marked to expire, the UNIX timestamp at which it will expire.
]]
function Kache:Set(key: any, value: any, ttl: number?)
	local cacheObj = { value = value }
	local expiresAt

	if (ttl or self._defaultTTL) ~= -1 then
		cacheObj.expiry = os.time() + (ttl or self._defaultTTL)
		expiresAt = cacheObj.expiry
	end

	self._items[key] = cacheObj
	self._cacheUpdate:Fire(Kache.Enum.Event.Set, key, cacheObj.value, cacheObj.expiry)

	return expiresAt
end

--[[
	Deletes an item from the cache if it exists.

	@param key The key the item is under.

	@returns The value that got removed.
]]
function Kache:Unset(key: any)
	if self._items[key] ~= nil then
		local value = self._items[key].value

		self._items[key] = nil
		self._cacheUpdate:Fire(Kache.Enum.Event.Unset, key, value)

		return value
	end
end

--[[
	Gets an item from cache, or runs the default (function) if one does not exist.

	@param key The key the item is under.
	@param default The default value to return if the key does not exist. If this is a function, call the function and use its return value.
	@param persistDefault If the key doesn't exist, persist the default value with default TTL.

	@returns The value from cache.
]]
function Kache:Get(key: any, default: any?, persistDefault: boolean?)
	local item = self._items[key]
	if item ~= nil then
		if item.expiry ~= nil and os.time() >= item.expiry then
			self:Unset(key)
		else
			return item.value
		end
	end

	-- if the key doesn't exist, it will fall through here

	if self._crossServer then
		local csItem
		yxpcall(function()
			csItem = self._dataStore:GetAsync(key)
		end, function(err)
			warn("[Kache] Failed to retrieve from cross-server cache datastore:", err)
		end)

		if csItem ~= nil then
			if csItem.expiry ~= nil and os.time() >= csItem.expiry then
				if self:Unset(key) == nil then
					self._cacheUpdate:Fire(Kache.Enum.Event.Unset, key, csItem.value) -- force fire the event anyway to trigger a cross-server unset
				end
			else
				self._items[key] = csItem -- write to the local cache but don't trigger an event or modify the item
				return csItem.value
			end
		end
	end

	local value
	if typeof(default) == "function" then
		value = default()
	else
		value = default
	end

	if persistDefault then
		self:Set(key, value)
	end

	return value
end

--[[
	Clears the cache.
]]
function Kache:Clear()
	self._items = {}

	self._cacheUpdate:Fire(Kache.Enum.Event.Clear)
end

--[[
	Cleans the cache of entries that are expired. This can be a heavy operation depending on the size of your cache.

	@returns The amount of entries cleaned up.
]]
function Kache:Clean()
	local entries = 0

	for k, v in pairs(self._items) do
		if v.expiry ~= nil and os.time() >= v.expiry then
			self:Unset(k)
			entries += 1
		end
	end

	return entries
end

--[[
	Counts the number of items in cache.

	@returns The number of items in cache.
]]
function Kache:Count()
	local count = 0
	for _ in pairs(self._items) do count += 1 end
	return count
end

type CacheEvent = typeof(Kache.Enum.Event)

--[[
	Connect to the cache event handler.

	@param callback The callback to fire when the cache is updated. Depending on the event, the callback will receive different arguments:
	On a Set event, the callback will receive the key, value, and expiry.
	On an Unset event, the callback will receive the key and value.
	On a Clear event, the callback will receive no arguments.

	A callback should use Kache.Enum.Event.<EventType> wherever possible to preserve event connections across updates.
]]
function Kache:Connect(callback: (CacheEvent, string, any, number?) -> nil)
	self._cacheUpdate.Event:Connect(callback)
end

--[[
	Yield until the next cache event.

	@returns The event arguments. See Kache:Connect(callback).
]]
function Kache:Wait()
	return self._cacheUpdate.Event:Wait()
end

return Kache