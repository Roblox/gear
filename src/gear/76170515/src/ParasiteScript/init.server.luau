--Fixed by Luckymaxer

Tool = script.Parent 
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

HelpGui = script:WaitForChild("HelpGui")
ParasiteAIScript = script:WaitForChild("ParasiteAIScript")

ParasiteId = 76117301
ParasiteModel = InsertService:LoadAsset(ParasiteId)
Parasite = ParasiteModel:GetChildren()[1]:Clone()
if ParasiteModel and ParasiteModel.Parent then
	ParasiteModel:Destroy()
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ToolEquipped = false

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function SummonParasite()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if HelpGuiClone and HelpGuiClone.Parent then
		HelpGuiClone.Frame.TextLabel.Text = "Command him to consume your enemies!"
	end
	ParasitePet = Parasite:Clone()
	local ParasiteAIScriptClone = ParasiteAIScript:Clone()
	local Target = Instance.new("ObjectValue")
	Target.Name = "Target"
	Target.Value = nil
	Target.Parent = ParasitePet
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = ParasitePet
	ParasiteAIScriptClone.Disabled = false
	ParasiteAIScriptClone.Parent = ParasitePet
	local ParasiteHumanoid = ParasitePet:FindFirstChild("Humanoid")
	if ParasiteHumanoid then
		ParasiteHumanoid.Died:connect(function()
			Debris:AddItem(ParasitePet, 4)
		end)
	end
	if ParasiteRemoved then
		ParasiteRemoved:disconnect()
	end
	ParasiteRemoved = ParasitePet.Changed:connect(function(Property)
		if Property == "Parent" and not ParasitePet.Parent then
			if HelpGuiClone and HelpGuiClone.Parent then
				HelpGuiClone.Frame.TextLabel.Text = "Summon the Parasite!"
			end
			Handle.Transparency = 0
		end
	end)
	Debris:AddItem(ParasitePet, 60)
	ParasitePet.Parent = game:GetService("Workspace")
	ParasitePet:MoveTo((Torso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))))
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	if not ParasitePet or not ParasitePet.Parent then
		Handle.Transparency = 1
		SummonParasite()
	end
	Tool.Enabled = false
	local TargetPosition = InvokeClient("MousePosition")
	local Direction = CFrame.new(Torso.Position, TargetPosition).lookVector
	local RayHit, RayPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Torso.Position, (Direction * 150)), {Character})
	if RayHit then
		local character = RayHit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and IsTeamMate(Player, player) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local Target = ParasitePet:FindFirstChild("Target")
			if Target then
				Target.Value = humanoid
			end
		end
	end
	wait(2)	
	Tool.Enabled = true
end

function SetMaxHealth(humanoid, MaxHealth)
	if not humanoid then
		return
	end
	local Ratio = (humanoid.Health / humanoid.MaxHealth)
	humanoid.MaxHealth = MaxHealth
	humanoid.Health = (Ratio * MaxHealth)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		HelpGuiClone = HelpGui:Clone()
		HelpGuiClone.Parent = PlayerGui
		HelpGuiClone.Frame.TextLabel.Text = "Summon the Parasite!"
	end
	Spawn(function()
		SetMaxHealth(Humanoid, 350)
	end)
	ToolEquipped = true
end 

function Unequipped()
	for i, v in pairs({ParasitePet, HelpGuiClone}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if ParasiteRemoved then
		ParasiteRemoved:disconnect()
	end
	Handle.Transparency = 0
	Spawn(function()
		SetMaxHealth(Humanoid, 100)
	end)
	ToolEquipped = false 
end 

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)