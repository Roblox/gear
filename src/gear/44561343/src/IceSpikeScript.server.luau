local firingCharacter = script.Parent.ShooterTag.Value

local spikeConnection = nil

function iceSpikeHit(hit)
	if hit == nil or hit.Parent == nil then return false end
	
	hum = hit.Parent:FindFirstChild("Humanoid")
	if hum and hit.Parent ~= firingCharacter then
		hum:TakeDamage(5)
		hum.WalkSpeed = hum.WalkSpeed - 1
		if hum.WalkSpeed < 5 then hum.WalkSpeed = 5 end
		spikeConnection:disconnect()
	end
end


spikeConnection = script.Parent.Touched:connect(iceSpikeHit)
