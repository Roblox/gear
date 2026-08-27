local vCharacter = script.Parent 

local myHumanoid = vCharacter:FindFirstChild("Humanoid") 
local myTorso = vCharacter:FindFirstChild("Torso") 

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
local playerGui

local sg
local frame 
local darknessImg

local duration = 2.5

if vPlayer then 
	playerGui = vPlayer:FindFirstChild("PlayerGui")
	if playerGui and playerGui:FindFirstChild("DarknessGui") == nil then 
		sg = Instance.new("ScreenGui")
		sg.Name = "DarknessGui"
		sg.Parent = playerGui 

		frame = Instance.new("Frame")
		frame.Name = "DarknessFrame"
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Position = UDim2.new(0, 0, 0, 0)
		frame.BackgroundTransparency = 1.0 
		frame.Parent = sg
		
		darknessImg = Instance.new("ImageLabel")
		darknessImg.Image = "http://www.roblox.com/asset/?id=68915275"
		darknessImg.BackgroundTransparency = 1.0
		darknessImg.Position = UDim2.new(0, 0, 0, 0)
		darknessImg.Size = UDim2.new(1, 0, 1, 0)
		darknessImg.Parent = frame 


		while duration > 0 do 
			duration = duration - wait()
			wait()
		end 
					
		if sg then sg:Remove() end
		wait(2.5)
		script:Remove()
	end 
end 

wait(2.0)
if script then script:Remove() end



