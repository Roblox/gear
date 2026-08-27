--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

EggSplatModel = InsertService:LoadAsset(228153674)
EggSplat = EggSplatModel:GetChildren()[1]:Clone()
if EggSplatModel and EggSplatModel.Parent then
	Debris:AddItem(EggSplatModel, 1)
end
EggSplat.Anchored = false

EggSplatScript = script:WaitForChild("EggSplatScript")

Images = {225903962, 225904058, 225904105, 225904147, 225904216}

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {
	EggSplat = script:WaitForChild("EggSplat"),
	EggCrack = script:WaitForChild("EggCrack"),
}

Broken = false


ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet", "Egg"}

Rate = (1 / 60)

Creator = script:WaitForChild("Creator")

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function CreateEggSplatter(Hit)
	local EggSplatClone = EggSplat:Clone()
	local EggSplatScriptClone = EggSplatScript:Clone()
	local CreatorClone = Creator:Clone()
	CreatorClone.Value = Creator.Value
	CreatorClone.Parent = EggSplatScriptClone
	EggSplatScriptClone.Disabled = false
	EggSplatScriptClone.Parent = EggSplatClone
	EggSplatClone.Size = (EggSplatClone.Size * (math.random(50, 200) * 0.01))
	if Hit and Hit.Object and Hit.Object.Parent and Hit.RayData then
		local PartCFrame = CFrame.new(Hit.RayData.RayPos, (CFrame.new(Hit.RayData.RayPos) + Hit.RayData.RayNormal * 2).p) * CFrame.Angles(-(math.pi / 2), (math.random(-360, 360) * 0.01), 0)
		PartCFrame = (PartCFrame * CFrame.new(0, (EggSplatClone.Size.Y / 1), 0))
		local Weld = Instance.new("Motor")
		Weld.Name = "Weld"
		Weld.Part0 = EggSplatClone
		Weld.Part1 = Hit.Object
		Weld.C0 = PartCFrame:inverse()
		Weld.C1 = Hit.Object.CFrame:inverse()
		Weld.Parent = EggSplatClone
		Debris:AddItem(EggSplatClone, 10)
		EggSplatClone.Parent = game:GetService("Workspace")
	end
end

function CoverScreen(player)
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if PlayerGui then

		local ScreenGui = Instance.new("ScreenGui") 
		ScreenGui.Name = "SlimeSplatter"
		local MainFrame = Instance.new("Frame") 
		MainFrame.Name = "Splater"
		MainFrame.Position = UDim2.new(0, 0, 0, 0) 
		MainFrame.Size = UDim2.new(1, 0, 1, 0) 
		MainFrame.BackgroundColor = BrickColor.new(1, 1, 1)
		MainFrame.Transparency = 1
		MainFrame.BorderColor = BrickColor.new(1, 1, 1)
		MainFrame.Parent = ScreenGui
	
		for i = 1, math.random(1, 4) do
			local Splatter = Instance.new("ImageLabel")
			local Size = ((math.random() * 1) + 0.25)
			Splatter.Size = UDim2.new(Size, 0, Size, 0)
			Splatter.Position = UDim2.new((math.random() - (Size / 2)), 0, (math.random() - (Size / 2)), 0)
			Splatter.SizeConstraint = Enum.SizeConstraint.RelativeXX
			Splatter.Transparency = 1
			Splatter.Image = (BaseUrl .. Images[math.random(1, #Images)])
			Splatter.Parent = MainFrame
			Splatter.Rotation = math.random(0, 360)
			Debris:AddItem(Splatter, (5 + (math.random() * 2)))
		end
		
		Debris:AddItem(ScreenGui, 5)
		
		ScreenGui.Parent = PlayerGui
	
	end
end

function Splat(Hit)
	if not Hit or not Hit.Parent or Broken then
		return
	end
	local Player = Creator.Value
	local Character = (((Player and Player.Parent and Player:IsA("Player") and Player.Character) and Player.Character) or nil)
	local HumanoidHit = false
	local character = Hit.Parent
	if character:IsA("Accessory") then
		character = Hit.Parent
	end
	if character == Character or character.Parent == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local player = Players:GetPlayerFromCharacter(character)
		if player and player ~= Player then
			CoverScreen(player)
		end
		local HumanoidHit = true
	end
	if HumanoidHit then
		local Sound = Sounds.EggSplat:Clone()
		Sound.Pitch = (math.random(1500, 2500) * 0.001)
		Sound.Parent = Part
		Sound:Play()
	else
		local Sound = Sounds.EggCrack:Clone()
		Sound.Pitch = (math.random(1000, 1500) * 0.001)
		Sound.Parent = Part
		Sound:Play()
		local RayHit, RayPos, RayNormal = CastRay(Part.Position, (Part.Velocity.unit * -1), ((Part.Size.Y / 2) + 10), {Part}, false)
		if RayHit then
			Spawn(function()
				CreateEggSplatter({Object = RayHit, RayData = {RayPos = RayPos, RayNormal = RayNormal}})
			end)
		end
	end
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Broken = true
	Debris:AddItem(Part, 2)
end

Part.Touched:connect(Splat)