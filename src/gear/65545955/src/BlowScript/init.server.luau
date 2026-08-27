local Grenade = script.Parent

while Grenade:FindFirstChild("Sparkles") == nil do wait() end

while script:FindFirstChild("DanceScript") == nil do
	wait()
end

while script:FindFirstChild("BOOM") == nil do 
	wait()
end

local boom = script.BOOM
boom:Play() 

local duration = 2.2

local sparkles = Grenade.Sparkles 
sparkles.Enabled = true

while duration > 0 do 
	tick()
	duration = duration - wait()
	wait()
	sparkles.SparkleColor = Color3.new(math.random(), math.random(), math.random())
end

local AOE = Vector3.new(14, 14, 14)

local players = game.Players:GetChildren()

for i = 1, #players do 
	if players[i] and players[i].Character and players[i].Character.Torso and players[i].Character:FindFirstChild("DanceScript") == nil then 
		local torso = players[i].Character.Torso 
		local distance = (Grenade.Position - torso.Position).magnitude
		if distance < 20.0 then
			local cloneScript = script.DanceScript:Clone()
			cloneScript.Parent = players[i].Character 
			cloneScript.Disabled = false 
		end
	end
end

if boom then boom:Stop() end
if Grenade then Grenade:Remove() end


