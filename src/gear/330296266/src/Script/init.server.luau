--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Reindeer = require(script:WaitForChild("Reindeer"))

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Rate = (1 / 60)

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function SpawnReindeer(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local BeforeCFrame = Torso.CFrame
	local ReindeerCopy = Reindeer:Clone()
	local Body = ReindeerCopy.Body
	local TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = Body,
		C0 = CFrame.new(-0.25, -0.3, -0.9),
		C1 = CFrame.new(0, 0, 0),
		Parent = Body
	}
	ReindeerCopy.Parent = Tool
	local RayHit, RayPos, RayNormal = RayCast(BeforeCFrame.p, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
	if RayHit then
		Torso.CFrame = (BeforeCFrame + Vector3.new(0, ((Torso.Size.Y / 2) + 2.5), 0))
		Torso.Velocity = Vector3.new(0, 0, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		SpawnReindeer(true)
	end)
	Handle.Transparency = 1
end

function Unequipped()
	SpawnReindeer(false)
	ToolEquipped = false
	Handle.Transparency = 0
end

SpawnReindeer(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)