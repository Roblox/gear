--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Functions = require(script:WaitForChild("Functions"))

DisableJumpScript = script:WaitForChild("DisableJump")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Player = Players:GetPlayerFromCharacter(Character)

Creator = script:FindFirstChild("Creator")
Mode = script:FindFirstChild("Mode")
Duration = script:FindFirstChild("Duration")

Connections = {}
Removing = false

function DestroyScript()
	if Removing then
		return
	end
	Removing = true
	if Humanoid then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs(Connections) do
		if v then
			v:disconnect()
		end
	end
	Debris:AddItem(script, 1)
end

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function PoisonDamage()
	local LastHurt = 0
	local PoisonDamage = RunService.Stepped:connect(function(Time, Step)
		local Now = tick()
		if (Now - LastHurt) >= 1.5 then
			LastHurt = Now
			if not Player or (Player and not Functions.IsTeamMate(Player, CreatorPlayer)) then
				Functions.UntagHumanoid(Humanoid)
				Functions.TagHumanoid(Humanoid, Player)
				Humanoid:TakeDamage(9)
			end
		end
	end)
	table.insert(Connections, PoisonDamage)
end

function Slow()
	Humanoid.WalkSpeed = 10
end

function DisableJump()
	local DisableJumpScriptCopy = DisableJumpScript:Clone()
	local Owner = Create("ObjectValue"){
		Name = "Owner",
		Value = script,
		Parent = DisableJumpScriptCopy,
	}
	DisableJumpScriptCopy.Disabled = false
	DisableJumpScriptCopy.Parent = Character
end

function ExtraDamage()
	IgnoreHealthChange = false
	CurrentHealth = Humanoid.Health
	local HealthChanged = Humanoid.Changed:connect(function(Property)
		local NewHealth = Humanoid.Health
		if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
			if NewHealth < CurrentHealth then
				local DamageDealt = (CurrentHealth - NewHealth)
				IgnoreHealthChange = true
				Humanoid.Health = (Humanoid.Health - (DamageDealt * 0.25))
				IgnoreHealthChange = false
			end
		end
		CurrentHealth = NewHealth
	end)
	table.insert(Connections, HealthChanged)
end

CreatorPlayer = GetCreator()

if not Humanoid or Humanoid.Health == 0 or not CreatorPlayer or not Mode or not Duration or Duration.Value <= 0 then
	DestroyScript()
	return
end

Spawn(function()
	print(Mode.Value)
	if Mode.Value == 1 then
		DisableJump()
	elseif Mode.Value == 2 then
		PoisonDamage()
	elseif Mode.Value == 3 then
		Slow()
	elseif Mode.Value == 4 then
		ExtraDamage()
	end
end)

wait(Duration.Value)

DestroyScript()