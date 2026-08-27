local AC = script.Parent

local CSB_Sound = AC:WaitForChild('CSBSound') 

local TConnection = AC.Touched:connect(function(hitPart)	
	if TConnection then TConnection:disconnect() end 	
	if AC:FindFirstChild('Fire') then
		AC.Fire.Enabled = false
	end
	
	if hitPart and hitPart.Parent then 
		local humanoid = hitPart.Parent:FindFirstChild('Humanoid')
		if humanoid then 
			humanoid:TakeDamage(100) 
		end 
		if CSB_Sound then CSB_Sound:Play() end 
	end 
	wait(0.25)
	local explosion = Instance.new('Explosion')
	explosion.BlastPressure = 99999
	explosion.BlastRadius = 4.0 
	explosion.Parent = AC
	explosion.Position = AC.CFrame.p	
end)

wait(4.0)
AC:Destroy() 

