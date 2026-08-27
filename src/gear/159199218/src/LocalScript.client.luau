--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Slash = Tool:WaitForChild("Slash")
LaserShot = Tool:WaitForChild("LaserShot")

LaserSound = Handle:WaitForChild("LaserSound")
SlashSound = Handle:WaitForChild("SlashSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false

SlashDamage = 15
LaserDamage = 65
ReloadTime = 1

LastClick = 0
Clicks = 0

SpecialDebounce = false
SpecialReload = 3

Grips = {
	NormalGrip = CFrame.new(0.25, 0, 1.54999995, 1, 8.90109959e-008, -0, -8.90109959e-008, 1, 0, 0, 0, 0.99999994),
	LaserShotGrip = CFrame.new(0.5, 0, 1, 0.707106769, -0, 0.707106769, 0, 1, 0, -0.707106769, 0, 0.707106769)
}

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

function Attack()
	if Tool.Enabled then
		Tool.Enabled = false
		SlashAnim = Humanoid:LoadAnimation(Slash)
		if SlashAnim then
			SlashSound:Play()
			SlashAnim:Play(0.1, nil, nil)
			Delay(0.9, function()
				if SlashAnim then
					SlashAnim:Stop()
				end
			end)
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function DoubleClick()
	SpecialCoolDown = true
	LaserShotAnim = Humanoid:LoadAnimation(LaserShot)
	if LaserShotAnim then
		LaserShotAnim:Play()
	end
	Tool.Grip = Grips.LaserShotGrip
	wait(0.5)
	if Equipped then
		SlashSound:Stop()
		LaserSound:Play()
		local Laser = Instance.new("Part")
		Laser.Name = "Laser"
		Laser.BrickColor = BrickColor.new("Lime green")
		Laser.Material = Enum.Material.Plastic
		Laser.Shape = Enum.PartType.Block
		Laser.FormFactor = Enum.FormFactor.Custom
		Laser.TopSurface = Enum.SurfaceType.Smooth
		Laser.BottomSurface = Enum.SurfaceType.Smooth
		Laser.Size = Vector3.new(0.2, 5, 0.2)
		Laser.Locked = true
		Laser.Anchored = false
		Laser.CanCollide = false
		Laser.Transparency = 0
		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshType = Enum.MeshType.Head
		Mesh.Parent = Laser
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, Laser:GetMass() * 196.20, 0)
		BodyForce.Parent = Laser
		local HandleClone = Handle:Clone()
		local HandleCloneY = HandleClone:Clone()
		HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
		HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * 0.125
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) + 0)
		local HandleCloneX = HandleCloneZ:Clone()
		HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
		HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * (HandleClone.Size.X / 2)
		Debris:AddItem(Laser, 5)
		Laser.Touched:connect(function(Hit)
			print(Hit)
			if Hit and Hit.Parent and Hit ~= Handle then
				Laser:Destroy()
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character and character ~= Character and humanoid and humanoid.Health > 0 then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(LaserDamage)
				end
			end
		end)
		Laser.Parent = game:GetService("Workspace")
		local TargetPoint = (HandleCloneX.CFrame + HandleCloneX.CFrame.lookVector * 1)
		Laser.CFrame = HandleCloneX.CFrame + Handle.CFrame.lookVector * (Laser.Size.Y / 2)
		Laser.Velocity = CFrame.new(Handle.Position, (Handle.CFrame + Handle.CFrame.lookVector * 2).p).lookVector * 100
		wait(1)
		if LaserShotAnim then
			LaserShotAnim:Stop()
		end
		Tool.Grip = Grips.NormalGrip
		wait(SpecialReload)
		SpecialCoolDown = false
	end
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(SlashDamage)
				end
			end
		end
	end
end

function Activated()
	local Tick = tick()
	if LastClick == 0 or (Tick - LastClick) <= 0.25 and not SpecialCoolDown then
		LastClick = Tick
		Clicks = Clicks + 1
		if Clicks >= 2 then
			LastClick = 0
			Clicks = 0
			if SlashAnim then
				SlashAnim:Stop()
			end
			DoubleClick()
		else
			Attack()
		end
	else
		Attack()
		Clicks = 1
		LastClick = Tick
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid then
		return
	end
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
	Tool.Grip = Grips.NormalGrip
	if SlashAnim then
		SlashAnim:Stop()
	end
	if LaserShotAnim then
		LaserShotAnim:Stop()
	end
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)