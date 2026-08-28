-- // Created by StarWars
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local world = workspace

local Cframe,NewRay = CFrame.new,Ray.new

local FindPartOnRay = world.FindPartOnRay

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
Humanoid.PlatformStand = false
local Owner = Character:WaitForChild("Owner")

local Head = Character:FindFirstChild("Head")
if Head then
	local Gui = Head:FindFirstChild("BillboardGui")
	if Gui then
		Gui.Enabled = true
		Debris:AddItem(Gui, 5)
	end
	
end

local function RayCast(start, direction)
	local NewRay = NewRay(start, direction * 999)
	
	local HitPart, Endpoint = FindPartOnRay(world,NewRay)
	
	return HitPart, Endpoint
end

local WheelMotor = Character:WaitForChild("Torso"):WaitForChild("Wheel")
WheelMotor.CurrentAngle = 0
WheelMotor.DesiredAngle = 999999
RunService.Heartbeat:Connect(function(delta)
	local OwnerModel = Owner and Owner.Value
	
	if OwnerModel and OwnerModel.PrimaryPart and Head then	
		local Direction = (OwnerModel.PrimaryPart.Position - Character.PrimaryPart.Position).Unit
		local Hit, Endpoint = RayCast(Character.PrimaryPart.Position, Direction)
		
		Humanoid:MoveTo((OwnerModel.PrimaryPart.CFrame * Cframe(4, 0, 4)).p)
		
		WheelMotor.MaxVelocity = (Head.Velocity.Magnitude > .1 and .1) or 0
	end
end)