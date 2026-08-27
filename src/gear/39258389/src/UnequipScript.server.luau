local Tool = script.Parent
local humanoid = nil
local vCharacter = Tool.Parent

while vCharacter == nil or vCharacter.Name == "Backpack" do
	if Tool ~= nil then vCharacter = Tool.Parent end
	Tool = script.Parent
	wait(1)
end

function onEquipped()
	if vCharacter ~= nil then humanoid = vCharacter:FindFirstChild("Humanoid") end
end

function onUnequipped()
	if humanoid ~= nil then
		print("secondaryUnequip")
		Tool.DanceObject.Value:Stop()
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
