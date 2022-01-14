local module = {}

module.new = function(Parent: GuiObject, Reaction, ZIndex: number?, UseInputEvents: boolean?): RBXScriptSignal
	local Button = Instance.new("TextButton")
	local Bindable = Instance.new("BindableEvent", Button)
	Button.Name = "Trigger"
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.ZIndex = ZIndex or Button.ZIndex
	Button.BackgroundTransparency = 1
	Button.Text = ""

	Button.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.Touch or InputObject.UserInputType == Enum.UserInputType.MouseMovement then
			Reaction(Parent, "Hover")
		end
	end)

	Button.InputEnded:Connect(function()
		Reaction(Parent, "Over")
	end)

	if UseInputEvents then
		Button.InputBegan:Connect(function(InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				Reaction(Parent, "Hold")
			end
		end)

		Button.InputEnded:Connect(function(InputObject)
			Bindable:Fire(InputObject.Position.X, InputObject.Position.Y)
		end)
	else
		Button.MouseButton1Down:Connect(function()
			Reaction(Parent, "Hold")
		end)

		Button.MouseButton1Up:Connect(function(X: number, Y: number)
			Bindable:Fire(X, Y)
		end)
	end

	Button.Parent = Parent
	return Bindable.Event
end

return module