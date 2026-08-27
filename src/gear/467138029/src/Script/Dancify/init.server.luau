--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

DisableJump = script:WaitForChild("DisableJump")

AnimationId = script:FindFirstChild("AnimationId")
Duration = script:FindFirstChild("Duration")
Weight = script:FindFirstChild("Weight")
Speed = script:FindFirstChild("Speed")

function DestroyScript()
	if AnimTrack then
		AnimTrack:Stop(0.5)
	end
	if DisableMobility then
		DisableMobility:disconnect()
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

DisableJumpCopy = DisableJump:Clone()
Controller = Create("ObjectValue"){
	Name = "Controller",
	Value = script,
	Parent = DisableJumpCopy,
}
DisableJumpCopy.Disabled = false
DisableJumpCopy.Parent = Character

Humanoid.WalkSpeed = 0

DisableMobility = Humanoid.Changed:connect(function(Property)
	if Property == "WalkSpeed" then
		Humanoid.WalkSpeed = 0
	elseif Property == "Jump" then
		Humanoid.Jump = false
	end
end)

Animation = Create("Animation"){
	AnimationId = (BaseUrl .. AnimationId.Value),
}

Duration = ((Duration and Duration.Value) or 5)
Weight = ((Weight and Weight.Value) or nil)
Speed = ((Speed and Speed.Value) or nil)

AnimTrack = Humanoid:LoadAnimation(Animation)

AnimTrack:Play(nil, Weight, Speed)

wait(Duration)

DestroyScript()