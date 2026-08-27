--By QuantumSama

function WaitForChild(parent, child)
	local result = parent:FindFirstChild(child)
	delay(3,function() if not result then print("Warning: Long wait for", child) end end)
	while not result do
		parent.ChildAdded:wait()
		result = parent:FindFirstChild(child)
	end
	return result
end

function WaitForChildren(parent, childTable)
	for i = 1, #childTable do
		WaitForChild(parent, childTable[i])
	end
end

local Tool = script.Parent
local Equipped = false

function onActivated()
	if Tool.Enabled and Equipped then
		Tool.Enabled = false
		Tool.Enabled = true
	end
end

local InitialGrip = Tool.Grip

function onEquipped(mouse)
	Equipped = true

	local outfitSelectorGui = WaitForChild(script,"OutfitSelectorGui")
	WaitForChild(outfitSelectorGui,"GuiSelector") 
	WaitForChildren(outfitSelectorGui.GuiSelector, {"CharRef", "SelectorScript", "OutfitScript", "Close", "Outfit1", "Outfit2", "Outfit3", "Outfit4"})
	WaitForChild(outfitSelectorGui.GuiSelector.OutfitScript, "OutfitNumber")

	mouse.Button1Down:connect(function()
		if mouse then
			local target = mouse.Target
			if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
				if target.Parent:FindFirstChild("OutfitScript") then return end
				local playerGui = game.Players.LocalPlayer.PlayerGui
				local currentSelector = playerGui:FindFirstChild("OutfitSelectorGui")
				if currentSelector then
					currentSelector.GuiSelector.CharRef.Value = target.Parent
				else
					local guiCopy = outfitSelectorGui:Clone()
					guiCopy.Parent = playerGui
					guiCopy.GuiSelector.CharRef.Value = target.Parent
					guiCopy.GuiSelector.SelectorScript.Disabled = false
				end
				--Tool.Grip = InitialGrip * CFrame.Angles(math.pi/2,0,0)
				--wait(.5)
				--Tool.Grip = InitialGrip
			end
		end
	end)
end

function onUnequipped()
	Equipped = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)
