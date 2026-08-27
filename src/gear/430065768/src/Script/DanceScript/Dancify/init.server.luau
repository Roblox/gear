local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local Character = script.Parent
local Humanoid = Character:FindFirstChild("Humanoid")

local DisableJump = script:WaitForChild("DisableJump")

local AnimationId = script:FindFirstChild("AnimationId")
local Duration = script:FindFirstChild("Duration")
local Weight = script:FindFirstChild("Weight")
local Speed = script:FindFirstChild("Speed")

local DisableJumpCopy = DisableJump:Clone()

function DestroyScript()
	if AnimTrack then
		AnimTrack:Stop(0.5)
	end
	if DisableMobility then
		DisableMobility:Disconnect()
	end
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end
	if DisableJumpCopy and DisableJumpCopy.Parent then
		Debris:AddItem(DisableJumpCopy, 1)
	end
	Debris:AddItem(script, 1)
end

if not AnimationId or not Humanoid or Humanoid.Health == 0 then
	DestroyScript()
	return
end

local Controller = Instance.new("ObjectValue")
Controller.Name = "Controller"
Controller.Value = script
Controller.Parent = DisableJumpCopy

DisableJumpCopy.Disabled = false
DisableJumpCopy.Parent = Character

Humanoid.WalkSpeed = 0

DisableMobility = Humanoid.Changed:Connect(function(Property)
	if Property == "WalkSpeed" then
		Humanoid.WalkSpeed = 0
	elseif Property == "Jump" then
		Humanoid.Jump = false
	end
end)

local Animation = Instance.new("Animation")
Animation.AnimationId = (BaseUrl .. AnimationId.Value)

Duration = ((Duration and Duration.Value) or 5)
Weight = ((Weight and Weight.Value) or nil)
Speed = ((Speed and Speed.Value) or nil)

AnimTrack = Humanoid:LoadAnimation(Animation)

AnimTrack:Play(nil, Weight, Speed)

wait(Duration)

DestroyScript()