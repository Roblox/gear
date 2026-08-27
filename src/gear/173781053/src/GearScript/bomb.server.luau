arrow = script.Parent
local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=18424769"
HitSound.Parent = arrow
HitSound.Volume = .5
function stick(hit)
	local weld = Instance.new("Weld")
	weld.Name = "PieWeld"
	weld.Part0 = arrow
	weld.Part1 = hit
	local HitPos = arrow.Position
	local CJ = CFrame.new(HitPos)
	local C0 = arrow.CFrame:inverse() *CJ
	local C1 = hit.CFrame:inverse() * CJ
	weld.C0 = C0
	weld.C1 = C1
	weld.Parent = arrow
end
function onTouched(hit)
	arrow.BodyGyro:remove()
	arrow.BodyForce:remove()
	connection:disconnect()
	stick(hit)
	HitSound:Play()	
end
connection = arrow.Touched:connect(onTouched)
for i=1,10 do
	wait(.1 * i)
	if (arrow:FindFirstChild("BodyGyro") ~= nil) then
		local v = arrow.Velocity.unit
		arrow.BodyGyro.maxTorque = Vector3.new(1e4,1e4,1e4)
		arrow.BodyGyro.cframe = CFrame.new(Vector3.new(0,150,0),  -v)
	end
end
wait(2)
if (arrow:FindFirstChild("PieWeld") ~= nil) then
	arrow.PieWeld:Remove()
end
wait(8)
arrow:Destroy();