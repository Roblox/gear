--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

AnimState = Tool:WaitForChild("AnimState")
AnimState.Value = false

Players = game:GetService("Players")
Debris = game:GetService("Debris")

HitEnabled = false

LionHat = Instance.new("Part")
LionHat.Name = "LionHat"
LionHat.Material = Enum.Material.Plastic
LionHat.Shape = Enum.PartType.Block
LionHat.FormFactor = Enum.FormFactor.Custom
LionHat.TopSurface = Enum.SurfaceType.Smooth
LionHat.BottomSurface = Enum.SurfaceType.Smooth
LionHat.Size = Vector3.new(1, 1.2, 1)
LionMesh = Instance.new("SpecialMesh")
LionMesh.MeshType = Enum.MeshType.FileMesh
LionMesh.MeshId = "http://www.roblox.com/asset/?id=90093552"
LionMesh.TextureId = "http://www.roblox.com/asset/?id=90093709"
LionMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
LionMesh.Parent = LionHat
LionFire = Instance.new("Fire")
LionFire.Color = Color3.new(255/255, 128/255, 0/255)
LionFire.SecondaryColor = Color3.new(94/255, 30/255, 5/255)
LionFire.Heat = 15
LionFire.Size = 8
LionFire.Enabled = false
LionFire.Parent = LionHat
RoarSound = Instance.new("Sound")
RoarSound.Name = "RoarSound"
RoarSound.Pitch = 1
RoarSound.SoundId = "http://www.roblox.com/asset/?id=90110171"
RoarSound.Volume = 0.5
RoarSound.Looped = false
RoarSound.Parent = LionHat

local HitFunction

local ReferenceLimbs = {"Left Arm", "Right Arm", "LeftHand", "LeftLowerArm", "LeftUpperArm", "RightHand", "RightLowerArm", "RightUpperArm"}


function ApplyRandForce(Limb)
	local TempForce = Instance.new("BodyForce")
	TempForce.Force = Vector3.new(((math.random() * 500) - 250), (math.random() * 500), ((math.random() * 500) - 250))
	Debris:AddItem(TempForce, 1)
	TempForce.Parent = Limb
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TearApart(Hit)
	if not Hit or not Hit.Parent or not HitEnabled then
		return
	end
	local humanoid,ff = Hit.Parent:FindFirstChildOfClass("Humanoid"),Hit.Parent:FindFirstChildOfClass("ForceField")
	if humanoid and humanoid ~= Humanoid and not ff and not IsTeamMate(Player,Players:GetPlayerFromCharacter(humanoid.Parent)) then
		local character = Hit.Parent
		HitEnabled = false
		local Limbs = {}
		for i, v in ipairs(ReferenceLimbs) do 
			local LimbPart = character:FindFirstChild(v)
			if LimbPart then
				table.insert(Limbs, LimbPart)
			end 
		end 
		if #Limbs > 0 then
		local Limb = Limbs[math.random(1, #Limbs)]
			if Limb and Limb.Parent then
				Limb.CanCollide = true
				Limb:BreakJoints()
				if LionHatClone and LionHatClone.Parent then
					LionHatClone.RoarSound:Play()
				end
				ApplyRandForce(Limb)
			end
			wait(2)
		end
		HitEnabled = true
	end
end

function Activated()
	if Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent then
		Tool.Enabled = false
		Handle.Transparency = 1
		LionHatClone = LionHat:Clone()
		LionHatClone.Parent = Character
		local Weld = Instance.new("Weld")
		Weld.Part0 = Head
		Weld.Part1 = LionHatClone
		Weld.C0 = CFrame.new(0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.C1 = CFrame.new(0, 1.5, 0, 0.999999583, 0, -0.000810325146, 0, 1, 0, 0.000810325146, 0, 0.999999583)
		Weld.Parent = LionHatClone
		LionHatClone.Fire.Enabled = true
		LionHatClone.RoarSound:Play()
		OldSpeed = Humanoid.WalkSpeed
		OldMaxHealth = Humanoid.MaxHealth
		OldHealth = Humanoid.Health
		Humanoid.WalkSpeed = (Humanoid.WalkSpeed * 1.5)
		Humanoid.MaxHealth = (Humanoid.MaxHealth * 1.5)
		Humanoid.Health = Humanoid.MaxHealth
		AnimState.Value = true
		HitEnabled = true
		local HitFunction = Torso.Touched:Connect(TearApart)
		
		wait(10)
		
		if HitFunction then
			HitFunction:Disconnect()
		end
		
		if LionHatClone and LionHatClone.Parent then
			LionHatClone:Destroy()
		end
		
		AnimState.Value = false
		
		Humanoid.WalkSpeed = OldSpeed
		Humanoid.MaxHealth = OldHealth
		Handle.Transparency = 0
		
		wait(5)
		
		Tool.Enabled = true
		
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Head or not Torso then
		return
	end
end

function Unequipped()
	if LionHatClone and LionHatClone.Parent then
		LionHatClone:Destroy()
	end
	if OldSpeed and OldMaxHealth and OldHealth then
		Humanoid.WalkSpeed = OldSpeed
		Humanoid.MaxHealth = OldMaxHealth
		Humanoid.Health = OldHealth
	end
	if HitFunction then
		HitFunction:Disconnect()
	end
	Handle.Transparency = 0
	AnimState.Value = false
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)