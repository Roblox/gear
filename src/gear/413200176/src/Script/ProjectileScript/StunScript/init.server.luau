--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

ClientScript = script:FindFirstChild("ClientScript")

EffectsBin = script:FindFirstChild("EffectsBin")
Effects = {}
if EffectsBin then
	for i, v in pairs(EffectsBin:GetChildren()) do
		Effects[v.Name] = v:Clone()
	end
end

Direction = script:FindFirstChild("Direction")
Force = script:FindFirstChild("Force")
Unlucky = script:FindFirstChild("Unlucky")

if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
	
	if Unlucky and Unlucky.Value ~= 0 and not Character:FindFirstChild("BadLuckEffected") then
		if EffectsBin then
			local Effect
			if Unlucky.Value == 1 then
				Effect = Effects.Trippy:Clone()
			elseif Unlucky.Value == 2 then
				Effect = Effects.Blur:Clone()
			elseif Unlucky.Value == 3 then
				Effect = Effects.Confusion:Clone()
			end
			if Effect then
				local BadLuckEffected = Create("BoolValue"){
					Name = "BadLuckEffected",
				}
				Debris:AddItem(BadLuckEffected, 15)
				BadLuckEffected.Parent = Character
				if ClientScript then
					Player = Players:GetPlayerFromCharacter(Character)
					if Player then
						local ClientScriptCopy = ClientScript:Clone()
						ClientScriptCopy.Disabled = false
						ClientScriptCopy.Parent = Character
					end
				end
				Effect.Disabled = false
				Effect.Parent = Character
			end
		end
	end
	--Humanoid.Sit = true
	Humanoid.PlatformStand = true
	Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	if Direction and Force then
		HumanoidRootPart.Velocity = (Direction.Value * Force.Value)
	else
		HumanoidRootPart.Velocity = ((HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)).lookVector * math.random(15, 35))
	end
	wait(3)
	Humanoid.PlatformStand = false
	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

Debris:AddItem(script, 0.5)