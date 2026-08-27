--Rescripted by Luckymaxer

local Piano = script.Parent

Piano.Touched:connect(function(hitPart)
	local Explosion = Instance.new("Explosion")
	Explosion.BlastPressure = 0
	Explosion.Parent = Piano
	Explosion.Position = Piano.CFrame.p
	Piano.Transparency = 1
	local Fire = Piano:FindFirstChild("Fire")
	if Fire then
		Fire.Enabled = false
	end
	wait(1)
	Piano:Destroy()
end)