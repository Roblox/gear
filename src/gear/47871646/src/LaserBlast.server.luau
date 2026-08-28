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

ball = script.Parent
damage = 25

local Creator = script:FindFirstChild("Creator")

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

debris = game:GetService("Debris")
debris:addItem(ball, 15)

local bpTable = {}
local startRadTable = {}
local startGrenPosTable = {}

local connection = nil
local blueFire = Instance.new("Fire")
local orangeFire = Instance.new("Fire")

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function onTouched(hit)
	if not hit or not hit.Parent then return end
	local humanoid,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")

	if humanoid and not FF or not IsTeamMate(Creator,game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent)) and game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent) ~= ((Creator and Creator.Value) or nil) then
		HitSound:Play()
		local torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
		if torso then
			local spinForce = torso:FindFirstChild("TornadeSpin")
			if not spinForce then 
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid,(Creator and Creator.Value) or nil)
				humanoid:TakeDamage(damage)
				local spinForce = Instance.new("BodyAngularVelocity")
				spinForce.P = 1000000
				spinForce.AngularVelocity = Vector3.new(0,50,0)
				spinForce.MaxTorque = Vector3.new(spinForce.P,spinForce.P,spinForce.P)
				spinForce.Name = "TornadeSpin"
				spinForce.Parent = torso
				debris:AddItem(spinForce, 4)
			end
			
			local newBV = torso:FindFirstChild("TornadeLift")
			if not newBV then
				newBV = Instance.new("BodyVelocity")
				newBV.Name = "TornadeLift"
				newBV.P = 100000
				newBV.MaxForce = Vector3.new(0, newBV.P, 0)
				newBV.Velocity = Vector3.new(0, 16, 0)
				newBV.Parent = torso
				debris:AddItem(newBV, 4)
			end
			
			local newBP = torso:FindFirstChild("TornadePos")
			if not newBP then
				newBP = Instance.new("BodyPosition")
				newBP.Name = "TornadePos"
				newBP.P = 100000
				newBP.MaxForce = Vector3.new(newBP.P, 0, newBP.P)
				newBP.Position = torso.Position
				newBP.Parent = torso
				table.insert(bpTable, newBP)
				table.insert(startRadTable, (torso.Position - ball.Position)*Vector3.new(1, 0, 1))
				table.insert(startGrenPosTable, ball.Position)
				blueFire.Parent = ball -- fire only appears if someone was hit :)
				orangeFire.Parent = ball
				debris:AddItem(newBP, 4)
			end
		end
	end

end

--while (ball.Velocity * Vector3.new(1, 0, 1)).magnitude > 8 or (ball.Velocity * Vector3.new(0,1,0)).magnitude > 1 do wait() end

wait(3) -- and the number of the counting shall be three

ball.CFrame =  CFrame.new(ball.Position) * CFrame.Angles(0, 0, 1)

blueFire.Name = "BlueFire"
blueFire.Heat = 50
blueFire.Size = 10
blueFire.Color = Color3.new(0, 0, 1)
blueFire.SecondaryColor = Color3.new(0, 1, 0)

orangeFire.Name = "OrangeFire"
orangeFire.Heat = -50
orangeFire.Size = 10
orangeFire.Color = Color3.new(1, 1, 0)
orangeFire.SecondaryColor = Color3.new(0, 1, 0)

--blueFire.Parent = ball

debris:AddItem(blueFire, 4)
debris:AddItem(orangeFire, 4)

local xPlosion = Instance.new("Explosion")
xPlosion.Name = "TornadeOw"
xPlosion.BlastRadius = 15
xPlosion.BlastPressure = 0
xPlosion.Position = ball.Position
xPlosion.Parent = game.Workspace

connection = xPlosion.Hit:Connect(onTouched)

-- remove grenade practically (it will be actually removed by debris service once wind forces are finished)
ball.Transparency = 1
local newBallFloat = Instance.new("BodyPosition")
newBallFloat.P = 100000
newBallFloat.MaxForce = Vector3.new(newBallFloat.P, newBallFloat.P, newBallFloat.P)
newBallFloat.Position = ball.Position
newBallFloat.Name = "FireFloat"
newBallFloat.Parent = ball

ball.CanCollide = false
ball.Velocity = Vector3.new(0,0,0)
ball.RotVelocity = Vector3.new(0,0,0)


while true do
	ball.CFrame = (CFrame.Angles(0, 0.7, 0)*(ball.CFrame-ball.Position)) + ball.Position
	for i = 1, #bpTable do
		bpTable[i].position = startGrenPosTable[i] + startRadTable[i]
		startRadTable[i] = CFrame.Angles(0, .7, 0)*startRadTable[i]
	end
	wait(.1)
end

