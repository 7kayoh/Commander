-- Network.lua
-- 7kayoh
-- Jan 16, 2022

local Network = {}

function Network._OnInit()
    Network._OnInit = nil
    require(script.EventRunner)
    require(script.FunctionRunner)
end

return Network