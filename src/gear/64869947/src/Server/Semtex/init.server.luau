local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
}

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

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local Bomb = script.Parent

local Creator = script:WaitForChild("Creator")

local Seed = Random.new()

local CountdownSound = Bomb:WaitForChild("FiveSecondCountdown")

local Touch
Touch = Bomb.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
		if not Hum or FF or Hum.Parent == Creator.Value.Character or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		Touch:Disconnect()
		Bomb.CanCollide = false
		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = hit
		Weld.Part1 = Bomb
		Weld.Parent = Bomb
		Bomb.Parent = hit.Parent
end)

CountdownSound.Ended:Connect(function()
	--print("EXPLOSION!")
	Bomb:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = false
	Bomb.Anchored = true
	local NinjaSounds = {Bomb:WaitForChild("Yell1"),Bomb:WaitForChild("Yell2"),Bomb:WaitForChild("Yell3")}
	local Sound = NinjaSounds[Seed:NextInteger(1,#NinjaSounds)]
	Sound:Play()
	Bomb:WaitForChild("ExplosionSound"):Play()
	local Explosion = Create("Explosion"){
		Position = Bomb.CFrame.p,
		BlastRadius = 10,
		DestroyJointRadiusPercent = 0,
		Visible = true,
		BlastPressure = 100000,
		Parent = workspace
	}
	local CapHumanoids = {}
	Explosion.Hit:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
		if not Hum or FF or Hum.Parent == Creator.Value.Character or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
			if not IsInTable(CapHumanoids,Hum) then 
				CapHumanoids[#CapHumanoids+1] = Hum
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Creator.Value)
			end
		hit.Velocity = (hit.CFrame.p-Explosion.Position).Unit*math.sqrt(Explosion.BlastPressure)
		hit:BreakJoints()
	end)
	Bomb.Transparency = 1
	Bomb.CanCollide = false
	wait(Sound.TimeLength+.5)
	Bomb:Destroy()
end)