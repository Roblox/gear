local flakes = {"28575797", "28575813", "28575821", "28575833", "28575848"}
local globs = {"28575761", "28575775"}

local debris = game:GetService("Debris")

wait(0.1)

function splashScreen(p)

	local guiMain = Instance.new("GuiMain") 
	guiMain.Parent = p.PlayerGui 
	local mainFrame = Instance.new("Frame") 
	mainFrame.Name = "WaterEffect"
	mainFrame.Position = UDim2.new(0, 0, 0, 0) 
	mainFrame.Size = UDim2.new(1, 0, 1, 0) 
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	mainFrame.Parent = guiMain

	debris:AddItem(guiMain, 10)

	--- big globs
	for i = 1,3 do

		local s = Instance.new("ImageLabel")
		local size = (math.random() * .2) + .5
		s.Size = UDim2.new(size,0,size,0)
		s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. globs[math.random(1, #globs)]
		s.Parent = mainFrame
		debris:AddItem(s, 5 + (math.random() * 2))

	end

	-- flakes
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


function onTouched(part)

	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then

		if script.Parent.Velocity.magnitude > 50 then 
			script.Parent.Splat:Play()
			local p = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			if not p then return end
			splashScreen(p)
			script.Parent.Transparency = 1
			wait(1)
			script.Parent:remove()
		elseif script.Parent.Velocity.magnitude > 60 then
			script.Parent.Splat:Play()
			script.Parent.Transparency = 1
			wait(1)
			script.Parent:remove()
		end

	end

end

script.Parent.Touched:connect(onTouched)
