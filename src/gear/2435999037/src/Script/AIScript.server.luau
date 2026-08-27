-- // Created by StarWars
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Niffler = script.Parent
local Humanoid = Niffler:WaitForChild("Humanoid")
local Owner = Niffler:WaitForChild("Owner")

local Head = Niffler:FindFirstChild("Head")
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
		local Direction = (OwnerModel.PrimaryPart.Position - Niffler.PrimaryPart.Position).Unit
		local Hit, Endpoint = RayCast(Niffler.PrimaryPart.Position, Direction)
		
		Humanoid:MoveTo((OwnerModel.PrimaryPart.CFrame * CFrame.new(4, 0, 4)).p)
	end
end)