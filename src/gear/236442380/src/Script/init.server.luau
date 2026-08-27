--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ControllerScript = script:WaitForChild("ControllerScript")
Remover = script:WaitForChild("Remover")

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Display = CFrame.new(-0.35, 1.7, 0, 8.10005167e-006, 0, -1, 0, 1, 0, 1, -0, 8.10005167e-006),
	Equipped = CFrame.new(-0.35, -0.125, 0, 8.10005167e-006, 0, -1, 0, 1, 0, 1, -0, 8.10005167e-006)
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

GearRecycler = BasePart:Clone()
GearRecycler.Name = "GearRecycler"
GearRecycler.Size = Vector3.new(0.75, 1.25, 0.75)
GearRecyclerMesh = Instance.new("SpecialMesh")
GearRecyclerMesh.MeshType = Enum.MeshType.FileMesh
GearRecyclerMesh.MeshId = (BaseUrl .. "233694481")
GearRecyclerMesh.TextureId = (BaseUrl .. "233694557")
GearRecyclerMesh.Scale = Vector3.new(1, 1, 1)
GearRecyclerMesh.Parent = GearRecycler

ReloadTime = 5

ToolEquipped = false

Tool.Grip = Grips.Equipped
Mesh.Scale = Vector3.new(1, 1, 1)
Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local GearRecyclerName = (Player.Name .. "'s" .. GearRecycler.Name)
	local GearRecyclerClone = game:GetService("Workspace"):FindFirstChild(GearRecyclerName)
	if GearRecyclerClone then
		GearRecyclerClone:Destroy()
		Handle.Transparency = 0
	else
		Handle.Transparency = 1
		local GearRecyclerClone = GearRecycler:Clone()
		GearRecyclerClone.Name = GearRecyclerName
		GearRecyclerClone.CFrame = Handle.CFrame
		LastGearRecycler = GearRecyclerClone
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = GearRecyclerClone
		local ControllerScriptClone = ControllerScript:Clone()
		ControllerScriptClone.Disabled = false
		ControllerScriptClone.Parent = GearRecyclerClone
		local RemoverClone = Remover:Clone()
		RemoverClone.Disabled = false
		RemoverClone.Parent = GearRecyclerClone
		GearRecyclerClone.Parent = game:GetService("Workspace")
	end
	wait(ReloadTime)
	if not LastGearRecycler or not LastGearRecycler.Parent then
		Handle.Transparency = 0
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and (((not LastGearRecycler or not LastGearRecycler.Parent) and 0) or 1)) or 0)
		if not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) and LastGearRecycler and LastGearRecycler.Parent then
			LastGearRecycler:Destroy()
			Handle.Transparency = 0
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)