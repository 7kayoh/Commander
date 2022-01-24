local remoteEvent = Instance.new("RemoteEvent")
local remoteFunction = Instance.new("RemoteFunction")

remoteEvent.Parent, remoteFunction.Parent = script.Parent, script.Parent
script:Destroy()