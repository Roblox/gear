ball = script.Parent
local fire = script.Parent
local debris = game:GetService("Debris")

BurnSound = Instance.new("Sound")
BurnSound.Name = "BurnSound"
BurnSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
-- constant sound: 31758982, burn something sound: 32791565 (or possibly 32791582)
BurnSound.Parent = ball
BurnSound.Volume = 1


function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end   -- weird sync issue
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid  ~= nil then
		if tostring(ball.creator.Value) == humanoid.Parent.Name then return end
		--if hit:FindFirstChild(fire.Name) == nil then
		if hit.Parent:FindFirstChild("Burner") == nil then BurnSound:Play() end
		if hit:FindFirstChild("Fire") == nil then
			burn = script.Burner:clone()
			burn.Parent = hit.Parent
			burn.Disabled = false
			local firer = Instance.new("Fire")
			firer.Color = Color3.new(1,117/255,57/255)
			firer.Parent = hit
			debris:AddItem(firer,12)
			--BurnSound:Play()
		end
	elseif hit.CanCollide then
		--ball.Parent = nil
		ball.Velocity = Vector3.new(0, 0, 0)
	end
end

connection = ball.Touched:connect(onTouched)

wait(1.1)
ball.Parent = nil
