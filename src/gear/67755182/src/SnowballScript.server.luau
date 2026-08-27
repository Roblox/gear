Cannon = script.Parent
debris = game:GetService("Debris")
local hitsounds = {"19326853", "19326880", "19326891"}
local flakes = {"66808700", "66808701", "66808703", "66808704", "66808705", "66808707", "66808711"}
local globs = {"66808543", "66808546"}

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=" .. hitsounds[math.random(1,#hitsounds)]
HitSound.Parent = Cannon
HitSound.Volume = 1

function Snowface(p)
	local guiMain = Instance.new("GuiMain") 
	guiMain.Parent = p.PlayerGui 
	local mainFrame = Instance.new("Frame") 
	mainFrame.Name = "SnowfaceEffect"
	mainFrame.Position = UDim2.new(0, 0, 0, 0) 
	mainFrame.Size = UDim2.new(1, 0, 1, 0) 
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	mainFrame.Parent = guiMain

	debris:AddItem(guiMain, 10)

	--- big glob
	local s = Instance.new("ImageLabel")
	local size = (math.random() * .2) + .5
	s.Size = UDim2.new(size,0,size,0)
	s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
	s.SizeConstraint = Enum.SizeConstraint.RelativeXX
	s.Transparency = 1
	s.Image = "http://www.roblox.com/asset/?id=" .. globs[math.random(1, #globs)]
	s.Parent = mainFrame

	debris:AddItem(s, 5 + (math.random() * 2))

	--flakes
	for i = 1, 20 do
		local s = Instance.new("ImageLabel")
		local size = (math.random() * .05) + .05
		s.Size = UDim2.new(size,0,size,0)
		s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. flakes[math.random(1, #flakes)]
		s.Parent = mainFrame
		debris:AddItem(s, 3 + (math.random() * 6))
	end
end

function Explode()
	local count = 5
	for i = 1, count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Pastel blue-green")
		p.formFactor = 2
		p.Size = Vector3.new(1,.4,1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0

		p.Velocity = Cannon.Velocity * (4 + (math.random() *2))
		p.RotVelocity = Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20,20))
		p.Position = Cannon.Position + (Cannon.Velocity * math.random() * .05) + Vector3.new(0,math.random() * 3, 0)
		p.Parent = game.Workspace

		debris:AddItem(p, 6)
	end
end




function onTouched(hit)
	connection:disconnect()
	HitSound:Play()
	if hit.Parent ~= nil then
		humanoid = hit.Parent:findFirstChild("Humanoid")
		if humanoid~=nil then
			local p = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			if (p ~= nil) then
			Snowface(p)
			end
		end
	end
	Explode()
	Cannon:Remove()	
end



connection = Cannon.Touched:connect(onTouched)

wait(10)

Cannon.Parent = nil