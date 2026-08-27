Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Speed = 100
Duration = 1

NozzleOffset = Vector3.new(0, 0.4, -1.1)

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Reload = Handle:WaitForChild("Reload"),
	HitFade = Handle:WaitForChild("HitFade")
}

PointLight = Handle:WaitForChild("PointLight")

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value, arg)
	if player ~= Player or Humanoid.Health == 0 or not Tool.Enabled then
		return
	end
	if Mode == "Click" and Value then
		Activated(arg)
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
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

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function GetTransparentsRecursive(Parent, PartsTable)
	local PartsTable = (PartsTable or {})
	for i, v in pairs(Parent:GetChildren()) do
		local TransparencyExists = false
		pcall(function()
			local Transparency = v["Transparency"]
			if Transparency then
				TransparencyExists = true
			end
		end)
		if TransparencyExists then
			table.insert(PartsTable, v)
		end
		GetTransparentsRecursive(v, PartsTable)
	end
	return PartsTable
end

function SelectionBoxify(Object)
	local SelectionBox = Instance.new("SelectionBox")
	SelectionBox.Adornee = Object
	SelectionBox.Color3 = Color3.new(0, 1, 0)
	SelectionBox.Parent = Object
	return SelectionBox
end

local function Light(Object)
	local Light = PointLight:Clone()
	Light.Range = (Light.Range + 2)
	Light.Parent = Object
end

function FadeOutObjects(Objects, FadeIncrement)
	repeat
		local LastObject = nil
		for i, v in pairs(Objects) do
			v.Transparency = (v.Transparency + FadeIncrement)
			LastObject = v
		end
		wait()
	until LastObject.Transparency >= 1 or not LastObject
end

function Dematerialize(character, humanoid, FirstPart)
	if not character or not humanoid then
		return
	end
	
	humanoid.WalkSpeed = 0

	local Parts = {}
	
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			table.insert(Parts, v)
		elseif v:IsA("LocalScript") or v:IsA("Script") then
			v:Destroy()
		end
	end

	local SelectionBoxes = {}

	local FirstSelectionBox = SelectionBoxify(FirstPart)
	Light(FirstPart)
	wait(0.05)

	for i, v in pairs(Parts) do
		if v ~= FirstPart then
			table.insert(SelectionBoxes, SelectionBoxify(v))
			Light(v)
		end
	end

	local ObjectsWithTransparency = GetTransparentsRecursive(character)
	FadeOutObjects(ObjectsWithTransparency, 0.1)

	wait(0.5)

	character:BreakJoints()
	humanoid.Health = 0
	
	Debris:AddItem(character, 2)

	local FadeIncrement = 0.05
	Delay(0.2, function()
		FadeOutObjects({FirstSelectionBox}, FadeIncrement)
		if character and character.Parent then
			character:Destroy()
		end
	end)
	FadeOutObjects(SelectionBoxes, FadeIncrement)
end

function Touched(Projectile, Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character, humanoid = FindCharacterAncestor(Hit)
	if character and humanoid and character ~= Character then
		local ForceFieldExists = false
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("ForceField") then
				ForceFieldExists = true
			end
		end
		if not ForceFieldExists then
			if Projectile then
				local HitFadeSound = Projectile:FindFirstChild(Sounds.HitFade.Name)
				local torso = humanoid.Torso
				if HitFadeSound and torso then
					HitFadeSound.Parent = torso
					HitFadeSound:Play()
				end
			end
			Dematerialize(character, humanoid, Hit)
		end
		if Projectile and Projectile.Parent then
			Projectile:Destroy()
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

function Activated(target)
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false

		InvokeClient("PlaySound", Sounds.Fire)

		local HandleCFrame = Handle.CFrame
		local FiringPoint = HandleCFrame.p + HandleCFrame:vectorToWorldSpace(NozzleOffset)
		local ShotCFrame = CFrame.new(FiringPoint, target)

		local LaserShotClone = BaseShot:Clone()
		LaserShotClone.CFrame = ShotCFrame + (ShotCFrame.lookVector * (BaseShot.Size.Z / 2))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.velocity = ShotCFrame.lookVector * Speed
		BodyVelocity.Parent = LaserShotClone
		LaserShotClone.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			Touched(LaserShotClone, Hit)
		end)
		Debris:AddItem(LaserShotClone, Duration)
		LaserShotClone.Parent = game:GetService("Workspace")

		wait(0.6) -- FireSound length

		InvokeClient("PlaySound", Sounds.Reload)
		
		wait(0.75) -- ReloadSound length

		Tool.Enabled = true
	end
end

function Unequipped()
	
end

BaseShot = Instance.new("Part")
BaseShot.Name = "Effect"
BaseShot.Color = Color3.new(0, 1, 0)
BaseShot.Material = Enum.Material.Plastic
BaseShot.Shape = Enum.PartType.Block
BaseShot.TopSurface = Enum.SurfaceType.Smooth
BaseShot.BottomSurface = Enum.SurfaceType.Smooth
BaseShot.Size = Vector3.new(0.2, 0.2, 3)
BaseShot.CanCollide = false
BaseShot.Locked = true
SelectionBoxify(BaseShot)
Light(BaseShot)
BaseShotSound = Sounds.HitFade:Clone()
BaseShotSound.Parent = BaseShot

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)