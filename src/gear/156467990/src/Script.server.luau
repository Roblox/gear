--Made by Luckymaxer
--[[
	Fixed by ArceusInator
--]]

local GLib = require(206209239)

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Anims = {
	Tool:WaitForChild("LeftSwing"),
	Tool:WaitForChild("RightSwing")
}

TauntAnim = Tool:WaitForChild("Taunt")

SlashSound = Handle:WaitForChild("Slash")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

OverseerAISpawnRadius = 10

Damage = 8

SpecialReady = true
SpecialReloadTime = 30

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "Click" and Value then
		Activated()
	elseif Mode == "KeyPress" and Value.Key == "q" and Value.Down and SpecialReady then
		ActivateSpecial()
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

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

function GetAllParts(Parent)
	local Parts = {}
	local function GetParts(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GetParts(v)
			if v:IsA("BasePart") then
				table.insert(Parts, v)
			end
		end
	end
	GetParts(Parent)
	return Parts
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		local targetPlayer = GLib.GetPlayerFromPart(humanoid)
		if Character and Player and Humanoid and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 and not GLib.IsTeammate(Player, targetPlayer) and (not humanoid:FindFirstChild'IsOverseerMinion' or humanoid:FindFirstChild'IsOverseerMinion'.Value~=Player) then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
				end
			end
		end
	end
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		InvokeClient("PlaySound", SlashSound)
		InvokeClient("PlayAnimation", {Animation = Anims[math.random(1, #Anims)], Speed = 0.8})
		wait(0.5)
		Tool.Enabled = true
	end
end

function ActivateSpecial()
	if Player and Character and Humanoid and Torso and SpecialReady then
		SpecialReady = false
		Tool.Enabled = false
		InvokeClient("PlayAnimation", {Animation = TauntAnim, Speed = 0.8})
		wait(5)
		for i = 1, 5 do
			local OverseerMinionModel = InsertService:LoadAsset(156242272)
			local OverseerMinion = OverseerMinionModel:GetChildren()[1]:Clone()
			local minionTag = Instance.new('ObjectValue', OverseerMinion.Humanoid)
			minionTag.Name = 'IsOverseerMinion'
			minionTag.Value = Player
			OverseerMinionModel:Destroy()
			OverseerMinion.Creator.Value = Player
			OverseerMinion:FindFirstChild("Humanoid").Died:connect(function()
				wait(1)
				local Parts = GetAllParts(OverseerMinion)
				for i, v in pairs(Parts) do
					if v and v.Parent then
						v.Anchored = true
					end
				end
				for i = 1, 100 do
					for i, v in pairs(Parts) do
						if v and v.Parent then
							v.Transparency = v.Transparency + 0.01
						end
					end
					wait(0.05)
				end
				for i, v in pairs(Parts) do
					if v and v.Parent then
						local Part = Instance.new("Part")
						Part.Name = "Effect"
						Part.Transparency = 1
						Part.FormFactor = Enum.FormFactor.Custom
						Part.Size = Vector3.new(0.2, 0.2, 0.2)
						Part.Anchored = true
						Part.CanCollide = false
						local Smoke = Instance.new("Fire")
						Smoke.Color = Color3.new(0, 0, 0)
						Smoke.SecondaryColor = Color3.new(0, 1, 0)
						Smoke.Size = 10
						Smoke.Heat = 100
						Smoke.Parent = Part
						Debris:AddItem(Part, 2)
						Part.Parent = game:GetService("Workspace")
						Part.CFrame = v.CFrame
						v:Destroy()
					end
				end
				OverseerMinion:Destroy()
			end)
			Debris:AddItem(OverseerMinion, (60 * 1.5))
			OverseerMinion.Parent = game:GetService("Workspace")
			wait()
			OverseerMinion:MakeJoints()
			local OverseerTorso = OverseerMinion:FindFirstChild("Torso")
			OverseerTorso.Anchored = true
			Delay(1, function()
				OverseerTorso.Anchored = false
			end)
			local SpawnPosition = Vector3.new(Torso.Position.X + math.random(-OverseerAISpawnRadius, OverseerAISpawnRadius), Torso.Position.Y, Torso.Position.Z + math.random(-OverseerAISpawnRadius, OverseerAISpawnRadius))
			OverseerMinion:MoveTo(SpawnPosition)
			local Part = Instance.new("Part")
			Part.Name = "Effect"
			Part.Transparency = 1
			Part.FormFactor = Enum.FormFactor.Custom
			Part.Size = Vector3.new(0.2, 0.2, 0.2)
			Part.Anchored = true
			Part.CanCollide = false
			local Smoke = Instance.new("Fire")
			Smoke.Color = Color3.new(0, 0, 0)
			Smoke.SecondaryColor = Color3.new(0, 1, 0)
			Smoke.Size = 10
			Smoke.Heat = 100
			Smoke.Parent = Part
			Debris:AddItem(Part, 2)
			Part.Parent = game:GetService("Workspace")
			Part.CFrame = CFrame.new(SpawnPosition) - Vector3.new(0, ((OverseerMinion:GetModelSize().y / 2) + (Part.Size.Y / 2)), 0)
			Delay(1, function()
				if Smoke and Smoke.Parent then
					Smoke.Enabled = false
				end
			end)
		end
		InvokeClient("StopAnimations", nil)
		Tool.Enabled = true
		wait(SpecialReloadTime)
		SpecialReady = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
	InvokeClient("StopAnimations", nil)
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)