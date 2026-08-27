--Made by Luckymaxer

Animations = {{73137669, 5}, {33796059, nil}, {27789359, nil}}
ChosenAnimation = Animations[math.random(1, #Animations)]

Humanoid = script.Parent

OriginalWalkSpeed = Humanoid.WalkSpeed

Humanoid.WalkSpeed = 0

Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)

Animation = Instance.new("Animation")
Animation.AnimationId = "http://www.roblox.com/asset?id=" .. ChosenAnimation[1]

AnimationTrack = Humanoid:LoadAnimation(Animation)

AnimationTrack:Play(nil, nil, ChosenAnimation[2])

Spawn(function()
	wait(15)
	local StopDance = Instance.new("StringValue")
	StopDance.Name = "StopDance"
	StopDance.Parent = DiscoBall
end)

script:WaitForChild("StopDance")

AnimationTrack:Stop()

Humanoid.WalkSpeed = OriginalWalkSpeed

script:Destroy()