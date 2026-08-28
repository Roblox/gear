local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle
local BaseSnowman = Tool:WaitForChild("Snowman"):Clone()
BaseSnowman.Transparency = 0
if BaseSnowman:FindFirstChild("Motor6D") then
	BaseSnowman.Motor6D:Destroy()
end
Tool.Snowman:Destroy()

local BaseHat = Handle:Clone()
if BaseHat:FindFirstChild("RightGripAttachment") then
	BaseHat.RightGripAttachment:Destroy()
end
BaseHat.CanCollide = true
BaseHat.Name = "Snowman Hat"

local Gear = GearService:BindGear(Tool)
Gear:SetupLocalScript("MouseIcon")

local CurrentSnowman = nil

Gear:BindActivateFunction("snowman_activate", function()
	if CurrentSnowman then
		CurrentSnowman:Destroy()
	end
	local Direction = Gear.RootPart.CFrame.lookVector
	local NewHat = BaseHat:Clone()
	NewHat.CFrame = Handle.CFrame
	NewHat.Parent = workspace
	NewHat.Velocity = Handle.Velocity + (Direction * NewHat:GetMass() * 50)	
	spawn(function()
		repeat wait() until NewHat.Velocity.Magnitude < 0.1
		local Hit, Endpoint = GearService:CastRay(NewHat.CFrame.p, (NewHat.CFrame.p - NewHat.CFrame.p + Vector3.new(0, -1, 0)).Unit, 999, {NewHat, Gear.Character})
		if Hit then
			NewHat.CFrame = CFrame.new(Endpoint.X,Hit.Position.Y+Hit.Size.Y/2+NewHat.Size.Y/2,Endpoint.Z)
		end
		
		local SnowmanModel = Instance.new("Model")
		SnowmanModel.Name = Gear.Player.Name .. "'s_Snowman"
		SnowmanModel.Parent = workspace
		
		local NewSnowman = BaseSnowman:Clone()
		local NewSnowmanPosition = NewHat.CFrame * CFrame.new(0, -NewSnowman.Size.Y * 0.5, 0)
		NewSnowman.CFrame = CFrame.new(NewSnowmanPosition.p, Vector3.new(Gear.RootPart.Position.X, NewSnowmanPosition.p.Y, Gear.RootPart.Position.Z))
		GearService:WeldToAttachment(NewSnowman:FindFirstChild("SnowHatAttachment"), NewHat:FindFirstChild("SnowHatAttachment"))
		NewSnowman.CanCollide = true
		NewHat.CanCollide = false		
		NewSnowman.Parent = SnowmanModel
		NewHat.Parent = SnowmanModel
		SnowmanModel.PrimaryPart = NewSnowman
		CurrentSnowman = SnowmanModel
		wait()
		if NewSnowman then
			NewSnowman.Anchored = true
		end
	end)
		
	Handle.Transparency = 1 
	wait(5)
	Handle.Transparency = 0
end)

Gear:BindUnequippedFunction("snowman_unequipped", function()
	if CurrentSnowman then
		CurrentSnowman:Destroy()
	end
	
	CurrentSnowman = nil
end)