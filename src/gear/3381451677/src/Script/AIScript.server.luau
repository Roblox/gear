-- // Created by StarWars
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Rat = script.Parent
local Humanoid = Rat:WaitForChild("Humanoid")
local RatTailAnimation = Rat:WaitForChild("Animation")
local Owner = Rat:WaitForChild("Owner")
local Offset = Rat:WaitForChild("Offset")

local Track = Humanoid:LoadAnimation(RatTailAnimation)
Track:Play()

local Head = Rat:FindFirstChild("Head")
if Head then
	local Gui = Head:FindFirstChild("BillboardGui")
	if Gui then
		Gui.Enabled = true
		Debris:AddItem(Gui, 5)
	end
	
end

local function RayCast(start, direction)
	local NewRay = Ray.new(start, direction * 999)
	
	local HitPart, Endpoint = workspace:FindPartOnRay(NewRay)
	
	return HitPart, Endpoint
end

RunService.Heartbeat:Connect(function(delta)
	local OwnerModel = Owner and Owner.Value
	
	if OwnerModel then	
		local Direction = (OwnerModel.PrimaryPart.Position - Rat.PrimaryPart.Position).Unit
		
		local Speed = Rat.PrimaryPart.Velocity.Magnitude
		
		Track:AdjustSpeed(Speed / Humanoid.WalkSpeed)
		
		Humanoid:MoveTo((OwnerModel.PrimaryPart.CFrame * CFrame.new(Offset.Value)).p)
	end
end)