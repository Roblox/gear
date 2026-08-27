--Rescripted by Luckymaxer

Parasite = script.Parent

Creator = Parasite:WaitForChild("Creator")
Target = Parasite:WaitForChild("Target")

Bite = script:WaitForChild("Bite")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Creator.Value
Character = Player.Character
Humanoid = Character:FindFirstChild("Humanoid")
Torso = Character:FindFirstChild("Torso")

ParasiteHumanoid = Parasite:FindFirstChild("Humanoid")
ParasiteTorso = Parasite:FindFirstChild("Torso")
ParasiteLeftArm = Parasite:FindFirstChild("Left Arm")
ParasiteRightArm = Parasite:FindFirstChild("Right Arm")
ParasiteRightMidArm = Parasite:FindFirstChild("Right MidArm")
ParasiteLeftMidArm = Parasite:FindFirstChild("Left MidArm")
ParasiteLeftForeArm = Parasite:FindFirstChild("Left ForeArm")
ParasiteRightForeArm = Parasite:FindFirstChild("Right ForeArm")

Animating = false

ParasiteHumanoid.WalkSpeed = 24
ParasiteHumanoid.MaxHealth = 350
ParasiteHumanoid.Health = ParasiteHumanoid.MaxHealth

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
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

function Slash(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character or character == Parasite then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid == EnemyHumanoid then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(15) 
		if (Humanoid.Health + 12) < Humanoid.MaxHealth then 
			Humanoid.Health = (Humanoid.Health + 12)
			if not Torso:FindFirstChild("Fire") then
				local Fire = Instance.new("Fire")
				Fire.Parent = Torso
				Fire.Name = "ParasiteFire"
				Fire.Color = Color3.new(0, 0, 0)
				Fire.SecondaryColor = Color3.new(1, 0, 0)
				Fire.Size = 4
				Debris:AddItem(Fire, 1.5)
			end 
		end
		if humanoid.Health == 0 then
			EnemyTorso = nil
		end
	end
end 

for i, v in pairs({ParasiteTorso, ParasiteLeftArm, ParasiteRightArm, ParasiteLeftForeArm, ParasiteRightForeArm, ParasiteLeftMidArm, ParasiteRightMidArm}) do
	if v then
		v.Touched:connect(Slash)
	end
end

Target.Changed:connect(function()
	if Target.Value then
		EnemyHumanoid = Target.Value
		Enemy = EnemyHumanoid.Parent
		local torso = Enemy:FindFirstChild("Torso")
		if torso then
			EnemyTorso = torso
		end
	end
end)

Animating = false
CheckAOE = Vector3.new(15, 15, 15)

while true do 
	local Ray = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(ParasiteTorso.Position, ParasiteTorso.CFrame.lookVector * 5), {Parasite})
	if Ray and ParasiteHumanoid.Health > 0 and Ray.Parent ~= Parasite and Ray.Parent ~= Character then
		ParasiteHumanoid.Jump = true
	end 
	if EnemyTorso then 		
		local Distance = (EnemyTorso.Position - ParasiteTorso.Position).magnitude
		local TargetEnemy = EnemyTorso.Parent
		if Distance < 60 then 
			local TargetEnemyHumanoid = TargetEnemy:FindFirstChild("Humanoid")		
			ParasiteHumanoid:MoveTo(EnemyTorso.Position)
			if Distance < 4 and not Animating then 
				Spawn(function()
					Animating = true
					local BiteAnim = ParasiteHumanoid:LoadAnimation(Bite)
					BiteAnim:Play()
					wait(1.25)
					Animating = false
				end)
			end
		else 
			ParasiteHumanoid:MoveTo(Torso.Position + Vector3.new(4, 0, 4))
		end 
	else
		ParasiteHumanoid:MoveTo(Torso.Position + Vector3.new(4, 0, 4))
	end
	wait()
end