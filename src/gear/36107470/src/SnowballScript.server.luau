arrow = script.Parent


debris = game:GetService("Debris")

local flakes = {"36043744", "36043787", "36043796", "36043810", "36043834"}
local globs = { "36043859", "36043881", "36043890"}

--local flakes = {"27133410", "27133432", "27133441", "27133456", "27133469"}
--local globs = {"27133482", "27133490","27133499"}

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=27127113"
HitSound.Parent = arrow
HitSound.Volume = 1

function Snowface(p)

	local guiMain = Instance.new("GuiMain") 
	guiMain.Parent = p.PlayerGui 
	local mainFrame = Instance.new("Frame") 
	mainFrame.Name = "PaintballEffect"
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
	for i=1,20 do

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

function Explode(part)

	if part.className == "Part" then
		
		overallSize = part.Size.x + part.Size.y + part.Size.z

		if overallSize < 40 then
			local origBrickColor = part.BrickColor
			part.BrickColor = arrow.BrickColor
			arrow.Transparency = 1
			arrow:Remove()
		end

	end

end




function onTouched(hit)

	connection:disconnect()

	if hit.Parent ~= nil then
		HitSound:Play()
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil then
			local p = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			if (p ~= nil) then
				humanoid:TakeDamage(2)
				Snowface(p)
				arrow.Transparency = 1
			end
		end
	end

	Explode(hit)
	
end



connection = arrow.Touched:connect(onTouched)

debris:AddItem(arrow,30)