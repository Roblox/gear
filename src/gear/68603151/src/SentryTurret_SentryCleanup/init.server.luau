function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Model = script.Parent
local Humanoid = Model:FindFirstChild("Humanoid")
local Player = (Model:FindFirstChild("TurretOwner") or {}).Value
local PlayerTurretValue = (Player or game):FindFirstChild("SentryValue")

if not (Model and Humanoid and Player and PlayerTurretValue) then
	print("FATAL: SentryCleaner setup failed, destroying turret!")
	Model:Destroy()
	Model.Parent = nil
end

game.Players.ChildRemoved:connect(function(p)
	if p == Player then
		--my player left, kill self
		Humanoid.Health = 0
	end
end)


Player.Changed:connect(function(prop, value)
	if prop == "Character" then
		local runner = script.SentryTurret_Sentry:Clone()
		local runnerTarget = Create'ObjectValue'{
			Name = 'MyTargetTurret',
			Value = Model,
			Parent = runner,
		}
		runner.Parent = Player.Character
		runner.Disabled = false
	end
end)


Humanoid.Died:connect(function()
	local partsToFade = {}
	for _, p in pairs(Model:GetChildren()) do
		if p:IsA("BasePart") then
			Create'Fire'{
				Name = 'FireEffect',
				Parent = p,
			}	
			partsToFade[#partsToFade+1] = p
		end
	end

	--remove this as current turret for player
	if PlayerTurretValue.Value == model then
		PlayerTurretValue.Value = nil
	end 
	
	--fade stuff
	for i = 0, 1, 0.05 do
		for _, p in pairs(partsToFade) do
			p.Transparency = i
		end
		wait()
	end

	--remove self
	Model:Destroy()
end)

--script.Name = "RUNNING_"..script.Name
while Humanoid.MaxHealth ~= 200 do
	wait()
	Humanoid.MaxHealth = 200
end
while Humanoid.Health ~= 200 do
	wait()
	local p = Humanoid.Parent
	Humanoid.Health = 200
	Humanoid.Parent = p
end
