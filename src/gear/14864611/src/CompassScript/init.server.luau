--Rescripted for the R15 update by StarWars
local Tool = script.Parent

local Enabled = true
local CompassArrow = require(script:WaitForChild("CompassArrow"))

function OnActivated()
	if not Enabled then return end
	
	Enabled = false
	
	Tool.Handle.OpenSound:Play()
	
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		CompassArrow.ActivateArrow(Character)
	end	
	
	wait(3)
	
	Enabled = true
end

function OnEquipped()
	Tool.Handle.OpenSound:play()
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)