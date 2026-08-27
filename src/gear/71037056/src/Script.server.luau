-- // Rescripted by StarWars
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Remotes = Tool.Remotes

local ServerControls = Remotes.ServerControls
local ClientControls = Remotes.ClientControls

local STRONGER_HEALTH = 250
local FASTER_WALKSPEED = 24
local DEFAULT_WALKSPEED = 16

local WAIT_TIME = 5
local MAX_DISTANCE = 12
local GENIE_ASSET_ID = 71006520
local GENIE_MODEL = InsertService:LoadAsset(GENIE_ASSET_ID):GetChildren()[1]
local GENIE_SPAWN_OFFSET = CFrame.new(4, 0, 4)

local ToolEquipped = false

local Player = nil
local Character = nil
local Humanoid = nil
local CurrentGenie = nil

local Animations =
{
	LampRub = {Animation = Tool.Animations.R6.LampAnim},
	R15LampRub = {Animation = Tool.Animations.R15.LampAnim}
}

function InvokeClient(Mode, Value)
	if Player then
		local Result = nil
		pcall(function()
			Result = ClientControls:InvokeClient(Player, Mode, Value)
		end)
		
		return Result
	end
end

function SummonGenie()
	if CurrentGenie then
		return
	end
	
	CurrentGenie = GENIE_MODEL:Clone()
	CurrentGenie.Parent = workspace
	CurrentGenie:SetPrimaryPartCFrame(Humanoid.RootPart.CFrame * GENIE_SPAWN_OFFSET)
	InvokeClient("SpawnGenie")
end

function CalculateTotalMass()
	local TotalMass = 0
	
	if Character then	
		for _, Part in next, Character:GetChildren() do
			if Part:IsA("BasePart") then
				TotalMass = TotalMass + Part:GetMass()
			end
		end
	end
	
	return TotalMass
end

function CheckIfAlive()
	return Player and Character and Humanoid and Humanoid.Health > 0 
end

Tool.Activated:Connect(function()
	if not Tool.Enabled or not CheckIfAlive() then return end
	
	Tool.Enabled = false
	local Animation = Animations.LampRub
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15LampRub
	end
	
	InvokeClient("PlayAnimation", Animation)
	delay(1, SummonGenie)
	wait(WAIT_TIME)
	Tool.Enabled = true
end)

Tool.Equipped:Connect(function()
	if ToolEquipped then return end 

	ToolEquipped = true
	
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)	
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	
	ToolEquipped = false
	
	if CurrentGenie then
		CurrentGenie:Destroy()
	end
	CurrentGenie = nil
	
	Character = nil
	Humanoid = nil
	Player = nil
end)

RunService.Heartbeat:Connect(function(Delta)
	if CurrentGenie and CurrentGenie:FindFirstChild("Humanoid") and Humanoid and Humanoid.RootPart then
		local Distance = (Humanoid.RootPart.CFrame.p - CurrentGenie.PrimaryPart.CFrame.p).Magnitude
		if Distance > MAX_DISTANCE then
			local RandomOffset = Vector3.new(math.random(2, 3), 0, math.random(2, 3))
			CurrentGenie.Humanoid:MoveTo(Humanoid.RootPart.CFrame.p + RandomOffset, Humanoid.RootPart)
		end
	end
end)

ServerControls.OnServerInvoke = function(ClientPlayer, Mode, Value)
	if ClientPlayer ~= Player or not Mode then return end 
	if Humanoid then
		if Mode == "MakeStronger" then
			local HealthPercentage = Humanoid.Health / Humanoid.MaxHealth
			Humanoid.MaxHealth = STRONGER_HEALTH
			Humanoid.Health = STRONGER_HEALTH * HealthPercentage
			delay(WAIT_TIME, function()
				if Humanoid then
					HealthPercentage = Humanoid.Health / Humanoid.MaxHealth
					Humanoid.MaxHealth = 100
					Humanoid.Health = 100 * HealthPercentage
				end
			end)	
		elseif Mode == "MakeFaster" then
			Humanoid.WalkSpeed = FASTER_WALKSPEED
			delay(WAIT_TIME, function()
				if Humanoid then
					Humanoid.WalkSpeed = DEFAULT_WALKSPEED
				end
			end)
		elseif Mode == "MakeFloat" then
			local BodyForce = Instance.new("BodyForce")
			BodyForce.Name = "Float"
			BodyForce.Force = Vector3.new(0, CalculateTotalMass() * workspace.Gravity * 1.1, 0)
			BodyForce.Parent = Humanoid.RootPart
			Debris:AddItem(BodyForce, WAIT_TIME)
		end
		
		if CurrentGenie then
			CurrentGenie:Destroy()
		end
		CurrentGenie = nil
	end
end