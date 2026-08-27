--Rescripted by Luckymaxer

Projectile = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local Hitsounds = {"19326853", "19326880", "19326891"}
local flakes = {"19003948", "19003957", "19003971", "19003978", "19003982", "19003990", "19003998"}
local globs = {"19323823", "19323854"}

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=" .. Hitsounds[math.random(1,#Hitsounds)]
HitSound.Parent = Projectile
HitSound.Volume = 1

Creator = script:FindFirstChild("Creator")

function GetCreator()
	return (((Creator and Creator.Value and Creator:IsA("Player")) and Creator.Value) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function Snowface(player)
	
	if not player then
		return
	end
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	
	local guiMain = Instance.new("ScreenGui") 
	guiMain.Parent = PlayerGui 
	local mainFrame = Instance.new("Frame") 
	mainFrame.Name = "SnowfaceEffect"
	mainFrame.Position = UDim2.new(0, 0, 0, 0) 
	mainFrame.Size = UDim2.new(1, 0, 1, 0) 
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	Debris:AddItem(guiMain, 10)
	mainFrame.Parent = guiMain

	--- big glob
	local s = Instance.new("ImageLabel")
	local size = (math.random() * .2) + .5
	s.Size = UDim2.new(size,0,size,0)
	s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
	s.SizeConstraint = Enum.SizeConstraint.RelativeXX
	s.Transparency = 1
	s.Image = "http://www.roblox.com/asset/?id=" .. globs[math.random(1, #globs)]
	Debris:AddItem(s, 5 + (math.random() * 2))
	s.Parent = mainFrame

	--flakes
	for i=1,20 do

		local s = Instance.new("ImageLabel")
		local size = (math.random() * .05) + .05
		s.Size = UDim2.new(size,0,size,0)
		s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. flakes[math.random(1, #flakes)]
		Debris:AddItem(s, 3 + (math.random() * 6))
		s.Parent = mainFrame
	end
	
end

function Explode()
	local count = 5
	for i = 1, count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Cool yellow")
		p.formFactor = 2
		p.Size = Vector3.new(1, 0.4, 1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0
		p.Velocity = Projectile.Velocity * (4 + (math.random() * 2))
		p.RotVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		p.CFrame = Projectile.CFrame + (Projectile.Velocity * math.random() * 0.05) + Vector3.new(0, math.random() * 3, 0)
		Debris:AddItem(p, 60)
		p.Parent = game:GetService("Workspace")
	end
end

AlreadyHit = false
function Touched(Hit)
	if not Hit or not Hit.Parent or AlreadyHit then
		return
	end
	local CreatorPlayer = GetCreator()
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			if (CreatorPlayer and player == Creator.Value) then
				return
			end
			Snowface(player)
		end
		AlreadyHit = true
	end
	HitSound:Play()
	Explode()
	Projectile:Destroy()
end

Projectile.Touched:connect(Touched)

wait(10)

Projectile:Destroy()