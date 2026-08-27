--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 0.5
ReloadAmmoTime = 5

Meshes = {
	BowWithArrow = "http://www.roblox.com/asset?id=172088844",
	Bow = "http://www.roblox.com/asset?id=172088882",
	Arrow = "http://www.roblox.com/asset?id=172088909"
}

Grips = {
	BowWithArrow = CFrame.new(0, -0.4, 0.415, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Bow = CFrame.new(0, -0.4, 0.325, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Sounds = {
	Fire = Handle:WaitForChild("FireSound"),
	Hit = Handle:WaitForChild("HitSound")
}

Speed = 50

Gravity = 196.2

Damage = 12

Tool.Enabled = true
Tool.Grip = Grips.BowWithArrow
Mesh.MeshId = Meshes.BowWithArrow

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Arrow = Instance.new("Part")
Arrow.Name = "Arrow"
Arrow.Material = Enum.Material.Plastic
Arrow.Shape = Enum.PartType.Block
Arrow.TopSurface = Enum.SurfaceType.Smooth
Arrow.BottomSurface = Enum.SurfaceType.Smooth
Arrow.FormFactor = Enum.FormFactor.Custom
Arrow.Size = Vector3.new(0.2, 0.2, 1.25)
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = Meshes.Arrow
ArrowMesh.TextureId = "http://www.roblox.com/asset?id=172088944"
ArrowMesh.Scale = Vector3.new(1, 1, 1)
ArrowMesh.Parent = Arrow
ArrowSound = Sounds.Hit:Clone()
ArrowSound.Parent = Arrow

ArrowsShot = 0
ArrowStock = 15

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "Fire" and Tool.Enabled then
		local TargetInFront = math.acos((Value - Handle.Position).unit:Dot(Handle.CFrame.lookVector))
		if TargetInFront > (math.pi / 3) then
			return
		end
		if ArrowsShot >= ArrowStock then
			ArrowsShot = 0
			Tool.Enabled = false
			InvokeClient(Player, "PlayAnimation", nil)
			wait(ReloadAmmoTime)
			Tool.Enabled = true
			return
		end
		ArrowsShot = (ArrowsShot + 1)
		Tool.Enabled = false
		Tool.Grip = Grips.Bow
		Mesh.MeshId = Meshes.Bow
		Sounds.Fire:Play()
		local ArrowClone = Arrow:Clone()
		local HitDebounce = false
		local FireArrow = math.random(1, 20)
		local Fire
		if FireArrow == 1 then
			Fire = Instance.new("Fire")
			Fire.Parent = ArrowClone
		end
		ArrowClone.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or HitDebounce or Hit.Name == "Arrow" then
				return
			end
			if Hit.Parent == Character or Hit.Parent.Parent == Character then
				return
			end
			HitDebounce = true
			ArrowClone.HitSound:Play()
			local Weld = Instance.new("Weld")
			Weld.Part0 = Hit
			Weld.Part1 = ArrowClone
			local humanoid = Hit.Parent:FindFirstChild("Humanoid")
			if humanoid and humanoid ~= Humanoid then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(((not Fire and Damage) or 65))
				local StickCFrame = CFrame.new(Hit.CFrame.p, ArrowClone.Position) * CFrame.new(0, 0, -1) * CFrame.Angles((math.pi / 2), (math.random() * math.pi * 2), 0)
				Weld.C1 = StickCFrame:inverse() * Hit.CFrame
			else
				Weld.C1 = ArrowClone.CFrame:inverse() * Hit.CFrame
			end
			Weld.Parent = ArrowClone
			ArrowClone.CanCollide = false
		end)
		local Direction = CFrame.new(Handle.Position, Value)
		local Mass = (ArrowClone:GetMass() * Gravity)
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.cframe = Direction
		BodyGyro.Parent = ArrowClone
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyVelocity.velocity = Direction.lookVector * Speed
		BodyVelocity.Parent = ArrowClone
		ArrowClone.Velocity = BodyVelocity.velocity
		Debris:AddItem(ArrowClone, 5)
		ArrowClone.Parent = game:GetService("Workspace")
		ArrowClone.CFrame = Handle.CFrame + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (ArrowClone.Size.Z / 2))
		ArrowClone.CFrame = CFrame.new(ArrowClone.Position, Value)
		wait(ReloadTime)
		Tool.Grip = Grips.BowWithArrow
		Mesh.MeshId = Meshes.BowWithArrow
		Tool.Enabled = true
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Mode, Value)
	end)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)