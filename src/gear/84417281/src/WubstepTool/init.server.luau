--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

DanceScript = script:WaitForChild("DanceScript")
WubWub = Handle:WaitForChild("WubWub")

AOE = 15
AreaQueryInterval = 1

Duration = 8

function DestroyBoombox()
	if Wubstep and Wubstep.Parent then
		Wubstep:Destroy()
	end
	Handle.Transparency = 0
end

function CreateBoombox()
	
	Handle.Transparency = 1
	
	Wubstep = Handle:Clone()
	Wubstep.Transparency = 0
	Wubstep.CanCollide = true
	local WubSound = WubWub:Clone()
	WubSound.Parent = Wubstep
	Debris:AddItem(Wubstep, Duration)
	Wubstep.Parent = game:GetService("Workspace")
	WubSound:Play()

	Spawn(function() 
		while Wubstep and Wubstep.Parent do 
			for i, v in pairs(Players:GetChildren()) do
				if v:IsA("Player") and v.Character then
					local character = v.Character
					local torso = character:FindFirstChild("Torso")
					if torso and (Torso.Position - torso.Position).magnitude <= AOE then
						if not character:FindFirstChild(DanceScript.Name) then
							local DanceScriptClone = DanceScript:Clone()
							DanceScriptClone.Disabled = false
							Debris:AddItem(DanceScriptClone, 20)
							DanceScriptClone.Parent = character
						end
					end
				end
			end
			wait(AreaQueryInterval)
		end 
	end)
end

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if Wubstep and Wubstep.Parent then
		DestroyBoombox()
	else
		CreateBoombox()
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
end

function Unequipped()
	Equipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)