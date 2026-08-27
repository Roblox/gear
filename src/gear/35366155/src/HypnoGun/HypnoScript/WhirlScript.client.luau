print("Getting whirled!!")


--http://www.roblox.com/asset/?id=34377700 = cake

splats = script:FindFirstChild("Splats")
if splats == nil then
	splats = Instance.new("Sound")
	splats.Parent = script
	splats.Volume = 1
	splats.Name = "Splats"
	splats.SoundId = "http://www.roblox.com/asset/?id=34376514"
end

screen = script.Parent:FindFirstChild("WhirlScreen")
if screen == nil then
	print("Could not find screen in PlayerGUI")
end

whirl = screen:FindFirstChild("whirl")
if whirl == nil then
	print("Whirl could not be found")
end

--whirl.Visible = true

local vPlayer = screen.Parent.Parent
humanoid = vPlayer.Character:FindFirstChild("Humanoid")

--whirlTimer = screen.WhirlTimer
whirlStrength = screen.WhirlStrength

local endSize = 2.5
local startSize = 1.2
local speed = .1

while true do
	local i = startSize
	local iStep = speed
	--while whirlTimer.Value > 1 do
	local needToKill = false

	while whirlStrength.Value < 50 do
		needToKill = true
		whirl.Visible = true
		whirl.BackgroundTransparency = whirlStrength.Value/50
		i = i+iStep
		whirl.Size = UDim2.new(i, 1, i, 1)
		whirl.Position = UDim2.new(.5-i/2, 0, .5-i/2, 0)
		--whirlTimer.Value = whirlTimer.Value - 1
		whirlStrength.Value = whirlStrength.Value + .5
		if humanoid ~= nil then humanoid.WalkSpeed = 16*whirlStrength.Value/50 end
		if i >= endSize then iStep = -speed end
		if i <= startSize then iStep = speed end
		wait(.1)
	end

	if needToKill then
		--whirl.Position = UDim2.new(-1, 0, -1, 0)
		--whirl.Size = UDim2.new(0,5,0,5)
		-- expand screen a lot first
		whirl.BackgroundTransparency = 1
		while i < 4 do
			i = i+speed
			whirl.Size = UDim2.new(i, 1, i, 1)
			whirl.Position = UDim2.new(.5-i/2, 0, .5-i/2, 0)
			wait(.1)
		end
		if humanoid ~= nil then humanoid.WalkSpeed = 16 end
		whirl.Visible = false
	end

	wait(.5)
end
