local Duration = 5
local Players = (game:FindService("Players") or game:GetService("Players"))

local Self = script

local Character = Self.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local IsPlayer = Players:GetPlayerFromCharacter(Character)

if IsPlayer then
	local CamSpin = Self:WaitForChild("CamSpinServer")
	local DurationValue = Instance.new("NumberValue")
	DurationValue.Name = "Duration"
	DurationValue.Value = Duration
	DurationValue.Parent = CamSpin
	
	local Target = Instance.new("ObjectValue")
	Target.Name = "Target"
	Target.Value = IsPlayer
	Target.Parent = CamSpin
	
	CamSpin.Parent = IsPlayer:WaitForChild("PlayerGui")
	CamSpin.Disabled = false
end

if Humanoid then
	Humanoid.WalkSpeed = 5
	wait(Duration)
	Humanoid.WalkSpeed = 16
	
	Self:Destroy()
	--[[if not IsPlayer then
		
	end]]
end

