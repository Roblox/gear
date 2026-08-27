--Rescripted by StarWars
local Drone = script.Parent

local DAMAGE = 2

local Alive = true

local Head = Drone:WaitForChild("Head")
local Humanoid = Drone:WaitForChild("Humanoid")
local Torso = Drone:WaitForChild("Torso")
local Creator = Drone:WaitForChild("creator")

local function FindNearestTarget()
	local Closest = 1000
	local Target = nil
	for _, v in pairs(workspace:GetChildren()) do
		if v and v:IsA("Model") and v.Name ~= Drone.Name then
			local TargetHumanoid = v:FindFirstChildOfClass("Humanoid")
			local TargetTorso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso")
			if TargetHumanoid and TargetHumanoid.Health > 0 then
				local TargetPlayer = game.Players:GetPlayerFromCharacter(v)
				if Creator.Value ~= TargetPlayer then
					local Distance = (TargetTorso.Position - Torso.Position).Magnitude
					if Distance < Closest then
						Target = TargetTorso
						Closest = Distance
					end
				end
			end
		end
	end
	
	return Target
end

Torso.Touched:connect(function(hit)
	if hit and hit.Parent and hit.Parent.Name ~= Drone.Name and Alive then
		local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if HitHumanoid then
			local HitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
			if Creator.Value ~= HitPlayer then
				HitHumanoid:TakeDamage(DAMAGE)
			end
		end
	end
end)

Humanoid.HealthChanged:connect(function(health)
	if Humanoid then
		if Humanoid.Health <= 0 then
			Alive = false
			if Torso then
				Humanoid:Destroy()
				local NewFire = Instance.new("Fire")
				NewFire.Parent = Torso
				if Head then
					Head:Destroy()
				end
				wait(2)
			end
			Drone:Destroy()
		end
	else
		Alive = false
		Drone:Destroy()
	end
end)

while Alive do
	local Target = FindNearestTarget()
	if Target then
		local RandomPoint = Target.Position + Vector3.new((math.random() - 0.5) * 5, (math.random() - 0.5) * 5, (math.random() - 0.5) * 5)
		Humanoid:MoveTo(RandomPoint, Target)
		if math.random() < 0.25 then
			Humanoid.Jump = true
		end
	end
	
	wait(0.5 + math.random())
end