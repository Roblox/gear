--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

UpperSlash = Tool:WaitForChild("UpperSlash")
Charge = Tool:WaitForChild("Charge")
SlashSound = Handle:WaitForChild("SlashSound")
Fire = Handle:WaitForChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false
Charging = false
FireDebounce = false

SlashDamage = 10
FireDamage = 50

ReloadTime = 0.25
SpecialReloadTime = 10

Click = 0

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

function Attack()
	if Tool.Enabled then
		Tool.Enabled = false
		UpperSlashAnim = Humanoid:LoadAnimation(UpperSlash)
		if UpperSlashAnim then
			SlashSound:Play()
			UpperSlashAnim:Play(nil, nil, 1.25)
		end
		wait(0.75)
		if UpperSlashAnim then
			UpperSlashAnim:Stop()
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Humanoid or not Torso then
		return
	end
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Fire.Enabled = true
	Spawn(function()
		if FireDebounce then
			wait(SpecialReloadTime)
			FireDebounce = false
		end
	end)
	Mouse.Button1Down:connect(function()
		if Tool.Enabled then
			Charging = true
			Click = tick()
			ChargeAnim = Humanoid:LoadAnimation(Charge)
			if ChargeAnim then
				ChargeAnim:Play()
			end
		end
	end)
	Mouse.Button1Up:connect(function()
		if ChargeAnim then
			ChargeAnim:Stop()
		end
		if ((tick() - Click) <= 0.25 or FireDebounce) then
			Attack()
		else
			if Tool.Enabled and Charging then
				FireDebounce = true
				local FirePart = Instance.new("Part")
				FirePart.Name = "FirePart"
				FirePart.Shape = Enum.PartType.Block
				FirePart.FormFactor = Enum.FormFactor.Custom
				FirePart.TopSurface = Enum.SurfaceType.Smooth
				FirePart.BottomSurface = Enum.SurfaceType.Smooth
				FirePart.Material = Enum.Material.Plastic
				FirePart.Anchored = false
				FirePart.CanCollide = false
				FirePart.Locked = true
				FirePart.Transparency = 1
				FirePart.Size = Vector3.new(0.2, 0.2, 0.2)
				local FireParticles = Fire:Clone()
				FireParticles.Enabled = true
				FireParticles.Heat = 15
				FireParticles.Size = 10
				FireParticles.Parent = FirePart
				local BodyForce = Instance.new("BodyForce")
				BodyForce.force = Vector3.new(0, FirePart:GetMass() * 196.20, 0)
				BodyForce.Parent = FirePart
				FirePart.Touched:connect(function(Hit)
					if Hit and Hit.Parent then
						local character, humanoid = FindCharacterAncestor(Hit.Parent)
						if character and character ~= Character and humanoid and humanoid.Health > 0 then
							FirePart:Destroy()
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(FireDamage)
						end
					end
				end)
				Debris:AddItem(FirePart, 3)
				FirePart.Parent = game:GetService("Workspace")
				FirePart.CFrame = Handle.CFrame
				FirePart.CFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint)
				FirePart.Velocity = CFrame.new(FirePart.Position, Humanoid.TargetPoint).lookVector * 50
				wait(SpecialReloadTime)
				FireDebounce = false
			end
		end
		Charging = false
	end)
end

function Unequipped()
	Equipped = false
	Charging = false
	Fire.Enabled = false
	if ChargeAnim then
		ChargeAnim:Stop()
	end
	if UpperSlashAnim then
		UpperSlashAnim:Stop()
	end
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)