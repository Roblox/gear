--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

EffectScript = script:WaitForChild("EffectScript")

Creator = Part:FindFirstChild("Creator")

AlreadyHit = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Parent) and Creator.Value) or nil)
end

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or AlreadyHit then
		return
	end
	--[[local CreatorPlayer = GetCreator()
	if not CreatorPlayer then
		return
	end]]
	local Character = Hit.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health == 0 then
		return
	end
	if Character:FindFirstChild("EffectScript") then
		return
	end
	
	local Player = Players:GetPlayerFromCharacter(Character) --Only works on players, no NPCs.
	if not Player then
		return
	end
	
	AlreadyHit = true
	
	local EatScriptCopy = EffectScript:Clone()
	EatScriptCopy.Name = "EffectScript"
	local EffectPart = Part:Clone()
	EffectPart.CanCollide = false
	for i, v in pairs(EffectPart:GetChildren()) do
		if string.find(string.lower(v.ClassName), string.lower("Script")) then
			v:Destroy()
		end
	end
	local Effect = Create("ObjectValue"){
		Name = "Effect",
		Value = EffectPart:Clone(),
		Parent = EatScriptCopy,
	}
	EatScriptCopy.Disabled = false
	EatScriptCopy.Parent = Character
	
	Part:Destroy()
	
end)