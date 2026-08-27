local ball = script.Parent
local fire = script.Parent
local fireCount
local debris = game:GetService("Debris")

local fireSound = Instance.new("Sound")
fireSound.Name = "fireSound"
fireSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
fireSound.Parent = ball
fireSound.Volume = 1

function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end  
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid  ~= nil then
		if ball.creator.Value.Name == humanoid.Parent.Name then return end		
		if hit.Parent:FindFirstChild("BurnScript") == nil then fireSound:Play() end
		if hit:FindFirstChild("Fire") == nil then
			burn = script.BurnScript:clone()
			burn.Parent = hit.Parent
			burn.Disabled = false			
			local fire = Instance.new("Fire")
			fire.Color = Color3.new(205/255, 50/255, 120/255)
			fire.Parent = hit
			debris:AddItem(fire, 9)			
		end
	elseif hit.CanCollide then		
		ball.Velocity = Vector3.new(0, 0, 0)
	end
end

ball.Touched:connect(onTouched)

wait(1.1)
if ball then ball:Remove() end
