-- // Created by StarWars
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local ImaginaryFriend = script.Parent
local Humanoid = ImaginaryFriend:WaitForChild("Humanoid")
local Owner = ImaginaryFriend:WaitForChild("Owner")

local Head = ImaginaryFriend:FindFirstChild("Head")
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
		local Direction = (OwnerModel.PrimaryPart.Position - ImaginaryFriend.PrimaryPart.Position).Unit
		local Hit, Endpoint = RayCast(ImaginaryFriend.PrimaryPart.Position, Direction)
		
		Humanoid:MoveTo((OwnerModel.PrimaryPart.CFrame * CFrame.new(4, 0, 4)).p)
	end
end)