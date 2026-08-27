--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

ScaleModule = require(201433042)

Sounds = {
	Hit = Part:WaitForChild("Hit"),
}

ShrinkScript = script:WaitForChild("ShrinkScript")

Tool = Part:FindFirstChild("Tool")
if Tool then
	Tool = Tool.Value
end
Creator = Part:WaitForChild("Creator")

AlreadyHit = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function PartHit(Hit)
	local creator = GetCreator()
	local DestroyProjectile = false
	local HumanoidHit = false
	if not Hit or not Hit.Parent or not creator or AlreadyHit then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		DestroyProjectile = true
	else
		HumanoidHit = true
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		DestroyProjectile = true
		HumanoidHit = false
	elseif player then
		if player == creator then
			return
		elseif IsTeamMate(creator, player) then
			DestroyProjectile = true
		end
	end
	if HumanoidHit then
		local ShrinkScriptCopy = character:FindFirstChild(ShrinkScript.Name)
		if ShrinkScriptCopy then
			local Shrink = ShrinkScriptCopy:FindFirstChild("Shrink")
			if Shrink then
				Shrink.Value = true
			end 
		else
			ShrinkScriptCopy = ShrinkScript:Clone()
			local Values = {
				{Name = "Creator", Value = creator, Class = "ObjectValue"},
				{Name = "Tool", Value = Tool, Class = "ObjectValue"},
			}
			for i, v in pairs(Values) do
				local Creator = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = ShrinkScriptCopy,
				}
			end
			ShrinkScriptCopy.Disabled = false
			ShrinkScriptCopy.Parent = character
		end
		DestroyProjectile = true
	end
	if DestroyProjectile then
		AlreadyHit = true
		Sounds.Hit:Play()
		Part.Anchored = true
		Part.Transparency = 1
		Debris:AddItem(Part, 1.5)
	end
end

Part.Touched:connect(PartHit)