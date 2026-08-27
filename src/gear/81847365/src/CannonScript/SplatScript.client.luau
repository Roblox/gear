local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		wait()
	end 
	return parent[instance]
end 

local vCharacter = script.Parent 
local vPlayer = game.Players.LocalPlayer 
local vHumanoid = waitForChild(vCharacter, "Humanoid") 
vHumanoid.WalkSpeed = 0.0 

local RBX_Debris = game:GetService("Debris")

local PlayerGui = waitForChild(vPlayer, "PlayerGui")

local Potato_ScreenGui = Instance.new("ScreenGui")
Potato_ScreenGui.Name = "Potato Splat"
Potato_ScreenGui.Parent = PlayerGui

RBX_Debris:AddItem(Potato_ScreenGui, 6.0)

local Potato_Frame = Instance.new("Frame")
Potato_Frame.Name = "Potato SplatFrame"
Potato_Frame.BackgroundTransparency = 1.0
Potato_Frame.Size = UDim2.new(0, 336, 0, 322)
Potato_Frame.Position = UDim2.new(math.random(), 0, math.random(), 0) 
Potato_Frame.Parent = Potato_ScreenGui

local Potato_ImageLabel = Instance.new("ImageLabel")
Potato_ImageLabel.Name = "Potato Splat"
Potato_ImageLabel.BackgroundTransparency = 1.0 
Potato_ImageLabel.Size = UDim2.new(1, 0, 0, 0)
Potato_ImageLabel.Position = UDim2.new(0, 0, 0, 0)
Potato_ImageLabel.Parent = Potato_Frame 
Potato_ImageLabel.Image = "http://www.roblox.com/asset/?id=81696397"

wait(3.0)
vHumanoid.WalkSpeed = 16.0
wait(3.0)
script:Destroy() 
