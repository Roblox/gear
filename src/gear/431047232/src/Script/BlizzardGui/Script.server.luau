--Made by Luckymaxer

Gui = script.Parent
PlayerGui = Gui.Parent

Player = PlayerGui.Parent
Character = Player.Character
Humanoid = Character:FindFirstChild("Humanoid")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Gui:FindFirstChild("Creator")
Timer = Gui:WaitForChild("Timer")

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

BaseSpeed = 16

HurtTick = 0

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

if Humanoid then
	DisableJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
	Humanoid.WalkSpeed = (BaseSpeed / 2)
end

MonitorConnection = RunService.Stepped:connect(function()
	local Now = tick()
	if (Now - HurtTick) >= 0.5 then
		local DontHurt = false
		local CreatorPlayer
		if Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") then
			CreatorPlayer = Creator.Value
			if IsTeamMate(CreatorPlayer, Player) then
				DontHurt = true
			end
		end
		if not DontHurt then
			if CreatorPlayer then
				UntagHumanoid(Humanoid)
				TagHumanoid(Humanoid, CreatorPlayer)
			end
			Humanoid:TakeDamage(5)
		end
		HurtTick = Now
	end
	if (Now - Timer.Value) >= 1 then
		for i, v in pairs({MonitorConnection, DisableJump}) do
			if v then
				v:disconnect()
			end
		end
		if Humanoid then
			Humanoid.WalkSpeed = BaseSpeed
		end
		Debris:AddItem(Gui, 0.5)
		Gui:Destroy()
	end
end)