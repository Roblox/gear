--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 10
ReloadTime = 0.25

AnimPlaying = nil

StormGui = Tool:WaitForChild("StormGui")
StormRadius = 20

ControlFunction = (Tool:FindFirstChild("ControlFunction") or Instance.new("RemoteFunction"))
ControlFunction.Name = "ControlFunction"
ControlFunction.Parent = Tool

PlayersNearby = {}

Equipped = false

ControlFunction.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "AnimationPlaying" and not AnimPlaying then
		AnimPlaying = Value
		wait(Value.Duration)
		AnimPlaying = nil
	end
	return false
end)

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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

Handle.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or not Character then
		return
	end
	local HitParent = Hit.Parent
	if HitParent:IsA("Hat") or HitParent:IsA("Tool") then
		HitParent = HitParent.Parent
	end
	if Hit.Parent == Character then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local humanoid = HitParent:FindFirstChild("Humanoid")
	if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage((AnimPlaying and AnimPlaying.Damage) or Damage)
	end
end)

function GiveStormGui()
	Spawn(function()
		while Equipped do
			for i, v in pairs(Players:GetChildren()) do
				if v:IsA("Player") and v.Character  and v ~= Player then
					local PlayerGui = v:FindFirstChild("PlayerGui")
					local Torso = v.Character:FindFirstChild("Torso")
					if PlayerGui and Torso and not PlayerGui:FindFirstChild(StormGui.Name) and not CheckTable(PlayersNearby, v) then
						if (Torso.Position - Handle.Position).magnitude <= StormRadius then
							local StormGuiClone = StormGui:Clone()
							local Connection = Instance.new("ObjectValue")
							Connection.Name = "Connection"
							Connection.Value = Tool
							Connection.Parent = StormGuiClone
							StormGuiClone.LocalScript.Disabled = false
							table.insert(PlayersNearby, {Player = v, Gui = StormGuiClone})
							StormGuiClone.Parent = PlayerGui
						end
					end
				end
			end
			for i, v in pairs(PlayersNearby) do
				if v.Player and v.Player.Character then
					local Torso = v.Player.Character:FindFirstChild("Torso")
					if not Torso or (Torso and (Torso.Position - Handle.Position).magnitude > StormRadius) then
						if v.Gui and v.Gui.Parent then
							v.Gui:Destroy()
						end
						table.remove(PlayersNearby, i)
					end
				end
			end
			wait(0.5)
		end
	end)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	GiveStormGui()
end

function Unequipped()
	Equipped = false
	Character = nil
	for i, v in pairs(PlayersNearby) do
		if v.Gui and v.Gui.Parent then
			v.Gui:Destroy()
		end
	end
	PlayersNearby = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)