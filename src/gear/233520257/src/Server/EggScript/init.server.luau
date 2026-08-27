--Made by Luckymaxer

Character = script.Parent

Players = game:GetService("Players")

Egg = script:WaitForChild("Egg").Value

Player = Players:GetPlayerFromCharacter(Character)
Humanoid = Character:FindFirstChildOfClass("Humanoid")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

if Player then
	local Backpack = Player:FindFirstChild("Backpack")
	if Backpack then
		Backpack:ClearAllChildren()
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
	end
end

Humanoid.PlatformStand = true
Humanoid.AutoRotate = false

DisableScript = script:WaitForChild("DisableScript")

DisableScriptClone = DisableScript:Clone()
DisableScriptClone.Disabled = false
DisableScriptClone.Parent = Humanoid

Humanoid.WalkSpeed = 0

ResizeModule = require(201433042)
ScaleCharacter = ResizeModule.ScaleCharacter

Rate = (1 / 60)

for i = 1, 125 do
	if Humanoid.Health == 0 then
		break
	end
	local TorsoCFrame = Torso.CFrame
	ScaleCharacter(Character, 0.985, {MaintainCFrame = true})
	Torso.CFrame = TorsoCFrame
	local RayHit, RayPos, RayNormal = RayCast(Egg.Position, Vector3.new(0, -1, 0), ((Egg.Size.Y / 2) + 0.25), {Character})
	if not RayHit then
		Torso.CFrame = (Torso.CFrame * CFrame.new(0, -0.1, 0))
	end
	wait(Rate)
end

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") or v:IsA("Tool") then
		v:Destroy()
	end
end

Humanoid.Health = 0