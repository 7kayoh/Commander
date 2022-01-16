local module = {}
local TweenService = game:GetService("TweenService")

function module.new(object: Instance, tweeninfo: TweenInfo, goal): Tween
	local tween = TweenService:Create(object, tweeninfo, goal)
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	
	tween:Play()
	return tween
end

return module