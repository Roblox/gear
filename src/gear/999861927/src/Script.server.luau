local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Coin = Handle:Clone()

function Activated()
	if not Tool.Enabled then return end 
	Tool.Enabled = false
	
	Handle.Transparency = 1
	local NewCoin = Coin:Clone()
	NewCoin.RotVelocity = Vector3.new(math.random(25, 50), 0, 0)
	NewCoin.Velocity = Handle.Velocity + Vector3.new(0, 50, 0)
	NewCoin.CFrame = Handle.CFrame * CFrame.new(0, 0, -1)
	NewCoin.Parent = workspace
	Debris:AddItem(NewCoin, 5)
	
	wait(2)
	Handle.Transparency = 0
	Tool.Enabled = true 
end

Tool.Activated:Connect(Activated)