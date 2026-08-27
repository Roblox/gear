--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

ProjectileScript = script:WaitForChild("ProjectileScript")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseProjectile = BasePart:Clone()
BaseProjectile.Name = "Projectile"
BaseProjectile.Size = Vector3.new(0.2, 0.2, 1)
BaseProjectile.BrickColor = BrickColor.new("Really black")
BaseProjectile.CanCollide = false
BaseProjectile.Anchored = true
BaseProjectileMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshId = (BaseUrl .. "2697549"),
	TextureId = "",
	Scale = Vector3.new(0.2, 0.2, 0.3),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseProjectile,
}

Projectiles = {
	Vector3.new(-0.35, -0.25, -2.125),
	Vector3.new(-0.2125, -0.375, -1.95),
	Vector3.new(-0.125, -0.325, -2.175),
	Vector3.new(-0.0625, -0.1375, -1.95),
	Vector3.new(0.045, -0.35, -2.165),
	Vector3.new(0.275, -0.3, -2.1),
	Vector3.new(0.245, -0.165, -2),
	Vector3.new(0.405, -0.3, -2),
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

Gravity = 196.20

ReloadTime = 4
Damage = 8

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MousePosition = InvokeClient("MousePosition")
	if MousePosition then
		Sounds.Fire:Play()
		MousePosition = MousePosition.Position
		local CreatedProjectiles = {}
		for i, v in pairs(Projectiles) do
			local Offset = (Handle.CFrame * CFrame.new(v))
			local Direction = CFrame.new(Offset.p, MousePosition)
			local Orientation = (Direction * CFrame.Angles(0, 0, 0))
			local Projectile = BaseProjectile:Clone()
			Projectile.CFrame = Orientation
			table.insert(CreatedProjectiles, Projectile)
		end
		local CenterModel = Create("Model"){Name = "CenterModel"}
		for i, v in pairs(CreatedProjectiles) do
			local FakePart = v:Clone()
			FakePart.Parent = CenterModel
		end
		local ModelCFrame = CenterModel:GetModelCFrame()
		ModelCFrame = (ModelCFrame + ModelCFrame.lookVector * 3)
		for i, v in pairs(CreatedProjectiles) do
			local Direction = CFrame.new(v.Position, ModelCFrame.p)
			v.CFrame = Direction
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Damage", Class = "NumberValue", Value = Damage},
			}
			for ii, vv in pairs(Values) do
				local Value = Create(vv.Class){
					Name = vv.Name,
					Value = vv.Value,
					Parent = v,
				}
			end
			local ProjectileScriptCopy = ProjectileScript:Clone()
			ProjectileScriptCopy.Disabled = false
			ProjectileScriptCopy.Parent = v
			Debris:AddItem(v, 3)
			v.Parent = game:GetService("Workspace")
		end
		wait(ReloadTime)
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

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)