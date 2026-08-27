--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

SealModel = InsertService:LoadAsset(155681109)
SealAI = SealModel:GetChildren()[1]:Clone()
SealModel:Destroy()

SealSpawnRadius = 10

Seals = {}
Debounce = false

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function DisableTool()
	Tool.Enabled = false
	wait(20)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function Activated(Mouse)
	if #Seals == 0 then
		Debounce = true
		Handle.Transparency = 1
		local SealAIClone = SealAI:Clone()
		SealAIClone:FindFirstChild("Creator").Value = Player
		local SealTorso = SealAIClone:FindFirstChild("Torso")
		table.insert(Seals, SealAIClone)
		Debris:AddItem(SealAIClone, (60 * 2))
		SealAIClone.Parent = game:GetService("Workspace")
		SealTorso.CFrame = Torso.CFrame + Torso.CFrame.lookVector * (((Torso.Size.Z / 2) + (SealAIClone:GetModelSize().Z / 2)) * 1.25)
		for i, v in pairs(Seals) do
			local SealTorso = v:FindFirstChild("Torso")
			local SealHumanoid = v:FindFirstChild("Humanoid")
			if SealHumanoid then
				v.Changed:connect(function()
					if not v.Parent then
						for ii, vv in pairs(Seals) do
							if v == vv then
								table.remove(Seals, ii)
								if #Seals == 0 then
									DisableTool()
								end
							end
						end						
					end
				end)
				SealHumanoid.Died:connect(function()
					for ii, vv in pairs(Seals) do
						if v == vv then
							table.remove(Seals, ii)
							if #Seals == 0 then
								DisableTool()
							end
						end
						v:Destroy()
					end
				end)
			end
		end
		Debounce = false
	else
		for i, v in pairs(Seals) do
			if Mouse.Target then
				local character, humanoid = FindCharacterAncestor(Mouse.Target)
				if character and humanoid and humanoid.Health > 0 then
					v.Target.Value = character
					v.Mode.Value = "Attack"
				else
					v.Target.Value = nil
					v.WalkToPoint.Value = Mouse.Hit.p
					v.Mode.Value = "Wander"
				end
			else
				v.Target.Value = nil
				if v.Mode.Value == "Pause" then
					v.Mode.Value = "Follow"
				else
					v.Mode.Value = "Pause"
				end
			end
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and not Debounce then
			Activated(Mouse)
		end
	end)
end

function Unequipped()
	
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)